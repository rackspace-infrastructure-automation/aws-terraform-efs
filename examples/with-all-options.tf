provider "aws" {
  version = "~> 1.2"
  region  = "us-west-2"
}

module "vpc" {
  source = "git@github.com:rackspace-infrastructure-automation/aws-terraform-vpc_basenetwork//?ref=v0.0.6"

  vpc_name = "EFSTest-with-all-options"
}

resource "aws_kms_key" "efs-test-with-all-options" {
  description             = "EFS Test with all options"
  deletion_window_in_days = 7
}

resource "aws_route53_zone" "internal" {
  name   = "efstest"
  vpc_id = "${module.vpc.vpc_id}"
}

resource "aws_sns_topic" "efs_burst_alarm" {
  name = "EFS-with-all-options_ALARM"
}

resource "aws_sns_topic" "efs_burst_ok" {
  name = "EFS-with-all-options_OK"
}

module "efs" {
  source = "git@github.com:rackspace-infrastructure-automation/aws-terraform-efs//?ref=v0.0.4"

  name                            = "EFSTest-with-all-options"
  performance_mode                = "maxIO"
  provisioned_throughput_in_mibps = "1"
  encrypted                       = "true"
  kms_key_arn                     = "${aws_kms_key.efs-test-with-all-options.arn}"

  custom_tags = {
    foo = "bar"
  }

  vpc_id = "${module.vpc.vpc_id}"

  mount_ingress_security_groups       = ["${module.vpc.default_sg}"]
  mount_ingress_security_groups_count = 1

  mount_target_subnets       = ["${module.vpc.private_subnets}"]
  mount_target_subnets_count = 2

  create_parameter_store_entries = "false"
  create_internal_dns_record     = "true"
  internal_zone_id               = "${aws_route53_zone.internal.zone_id}"

  rackspace_managed      = "false"
  custom_alarm_sns_topic = ["${aws_sns_topic.efs_burst_alarm.arn}"]
  custom_ok_sns_topic    = ["${aws_sns_topic.efs_burst_ok.arn}"]
}
