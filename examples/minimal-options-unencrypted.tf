provider "aws" {
  version = "~> 1.2"
  region  = "us-west-2"
}

module "vpc" {
  source = "git@github.com:rackspace-infrastructure-automation/aws-terraform-vpc_basenetwork//?ref=v0.0.9"

  vpc_name = "EFSTest-minimal-options-unencrypted-1VPC"
}

resource "aws_security_group" "sftp" {
  name_prefix = "SFTP-"
  vpc_id      = module.vpc.vpc_id

  description = "Access to SFTP instance(s)"

  tags = {
    Name = "SFTP"
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_security_group_rule" "sftp_egress_all" {
  type              = "egress"
  from_port         = 0
  to_port           = 65535
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.sftp.id
}

resource "aws_security_group" "efs" {
  name_prefix = "EFS-"
  vpc_id      = module.vpc.vpc_id

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
  security_group_id = aws_security_group.efs.id
}

resource "aws_security_group_rule" "efs_ingress_tcp_2049_sftp" {
  type                     = "ingress"
  from_port                = 2049
  to_port                  = 2049
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.sftp.id
  security_group_id        = aws_security_group.efs.id
  description              = "Ingress from sftp (TCP:2049)"
}

module "efs" {
  source = "git@github.com:rackspace-infrastructure-automation/aws-terraform-efs//?ref=v0.0.8"

  encrypted       = "false"
  name            = "EFSTest-minimal-options-unencrypted"
  security_groups = [aws_security_group.efs.id]
  vpc_id          = module.vpc.vpc_id
}
