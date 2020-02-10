provider "aws" {
  version = "~> 2.2"
  region  = "us-west-2"
}

module "vpc" {
  source = "git@github.com:rackspace-infrastructure-automation/aws-terraform-vpc_basenetwork//?ref=v0.12.0"

  name = "EFSTest-with-all-options"
}

resource "aws_security_group" "sftp" {
  description = "Access to SFTP instance(s)"
  name_prefix = "SFTP-"
  vpc_id      = module.vpc.vpc_id

  tags = {
    Name = "SFTP"
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_security_group_rule" "sftp_egress_all" {
  cidr_blocks       = ["0.0.0.0/0"]
  from_port         = 0
  protocol          = "-1"
  security_group_id = aws_security_group.sftp.id
  to_port           = 65535
  type              = "egress"
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

resource "aws_security_group_rule" "efs_ingress_tcp_2049_sftp" {
  description              = "Ingress from sftp (TCP:2049)"
  from_port                = 2049
  protocol                 = "tcp"
  security_group_id        = aws_security_group.efs.id
  source_security_group_id = aws_security_group.sftp.id
  to_port                  = 2049
  type                     = "ingress"
}

resource "aws_kms_key" "efs-test-with-all-options" {
  deletion_window_in_days = 7
  description             = "EFS Test with all options"
}

resource "aws_route53_zone" "internal" {
  name   = "efstest"
  vpc_id = module.vpc.vpc_id
}

resource "aws_sns_topic" "efs_burst_alarm" {
  name = "EFS-with-all-options_ALARM"
}

module "efs" {
  source = "git@github.com:rackspace-infrastructure-automation/aws-terraform-efs//?ref=v0.12.0"

  create_internal_dns_record      = true
  create_parameter_store_entries  = false
  encrypted                       = true
  internal_zone_id                = aws_route53_zone.internal.zone_id
  kms_key_arn                     = aws_kms_key.efs-test-with-all-options.arn
  mount_target_subnets            = [module.vpc.private_subnets]
  mount_target_subnets_count      = 2
  name                            = "EFSTest-with-all-options"
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
