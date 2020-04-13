provider "aws" {
  version = "~> 2.7"
  region  = "us-west-2"
}

module "vpc" {
  source = "git@github.com:rackspace-infrastructure-automation/aws-terraform-vpc_basenetwork//?ref=v0.12.0"

  name = "EFSTest-minimal-options-unencrypted-1VPC"
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

module "efs" {
  source = "git@github.com:rackspace-infrastructure-automation/aws-terraform-efs//?ref=v0.12.0"

  encrypted       = false
  name            = "EFSTest-minimal-options-unencrypted"
  security_groups = [aws_security_group.efs.id]
  vpc_id          = module.vpc.vpc_id
}
