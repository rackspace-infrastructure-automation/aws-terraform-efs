terraform {
  required_version = ">= 0.12"
}

provider "aws" {
  version = "~> 2.7"
  region  = "us-west-2"
}

resource "random_string" "res_name" {
  length  = 8
  lower   = true
  number  = false
  special = false
  upper   = false
}

module "vpc" {
  source = "git@github.com:rackspace-infrastructure-automation/aws-terraform-vpc_basenetwork//?ref=master"

  name = "EFSTest-with-all-options-${random_string.res_name.result}"
}

resource "aws_security_group" "efs" {
  description = "Access to EFS mount targets"
  name_prefix = "EFS-"
  vpc_id      = module.vpc.vpc_id

  tags = {
    Name = "EFS"
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_security_group_rule" "efs_egress_all" {
  cidr_blocks       = ["0.0.0.0/0"]
  from_port         = 0
  protocol          = "-1"
  security_group_id = aws_security_group.efs.id
  to_port           = 65535
  type              = "egress"
}

resource "aws_kms_key" "efs_test_with_all_options" {
  description             = "EFS Test with all options"
  deletion_window_in_days = 7
}

resource "aws_route53_zone" "internal" {
  name = "efstest-${random_string.res_name.result}"

  vpc {
    vpc_id = module.vpc.vpc_id
  }
}

resource "aws_sns_topic" "efs_burst_alarm" {
  name = "EFS-with-all-options-${random_string.res_name.result}"
}

module "efs" {
  source = "../../module"

  create_internal_zone_record     = true
  create_parameter_store_entries  = false
  encrypted                       = true
  internal_zone_id                = aws_route53_zone.internal.zone_id
  kms_key_arn                     = aws_kms_key.efs_test_with_all_options.arn
  mount_target_subnets            = module.vpc.private_subnets
  mount_target_subnets_count      = 2
  name                            = "${random_string.res_name.result}-EFSTest-with-all-options"
  notification_topic              = [aws_sns_topic.efs_burst_alarm.arn]
  performance_mode                = "maxIO"
  provisioned_throughput_in_mibps = 1
  rackspace_managed               = false
  security_groups                 = [aws_security_group.efs.id]
  vpc_id                          = module.vpc.vpc_id

  tags = {
    foo = "bar"
  }
}
