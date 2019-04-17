provider "aws" {
  version = "~> 1.2"
  region  = "us-west-2"
}

resource "random_string" "res_name" {
  length  = 8
  upper   = false
  lower   = true
  special = false
  number  = false
}

module "vpc" {
  source = "git@github.com:rackspace-infrastructure-automation/aws-terraform-vpc_basenetwork//?ref=master"

  vpc_name = "EFSTest-with-all-options-${random_string.res_name.result}"
}

resource "aws_security_group" "efs" {
  name_prefix = "EFS-"
  vpc_id      = "${module.vpc.vpc_id}"

  description = "Access to EFS mount targets"

  tags = {
    Name = "EFS"
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_security_group_rule" "efs_egress_all" {
  type              = "egress"
  from_port         = 0
  to_port           = 65535
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = "${aws_security_group.efs.id}"
}

resource "aws_kms_key" "efs-test-with-all-options" {
  description             = "EFS Test with all options"
  deletion_window_in_days = 7
}

resource "aws_route53_zone" "internal" {
  name = "efstest-${random_string.res_name.result}"

  vpc = {
    vpc_id = "${module.vpc.vpc_id}"
  }
}

resource "aws_sns_topic" "efs_burst_alarm" {
  name = "EFS-with-all-options-${random_string.res_name.result}"
}

module "efs" {
  source = "../../module"

  name                            = "EFSTest-with-all-options-${random_string.res_name.result}"
  performance_mode                = "maxIO"
  provisioned_throughput_in_mibps = "1"
  encrypted                       = "true"
  kms_key_arn                     = "${aws_kms_key.efs-test-with-all-options.arn}"

  custom_tags = {
    foo = "bar"
  }

  security_groups = ["${aws_security_group.efs.id}"]
  vpc_id          = "${module.vpc.vpc_id}"

  mount_target_subnets       = ["${module.vpc.private_subnets}"]
  mount_target_subnets_count = 2

  create_parameter_store_entries = "false"
  create_internal_dns_record     = "true"
  internal_zone_id               = "${aws_route53_zone.internal.zone_id}"

  rackspace_managed  = "false"
  notification_topic = ["${aws_sns_topic.efs_burst_alarm.arn}"]
}
