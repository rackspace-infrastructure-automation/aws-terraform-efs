terraform {
  required_version = ">= 0.12"
}

provider "aws" {
  version = "~> 2.2"
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

  name = "EFSTest-minimal-options-${random_string.res_name.result}"
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

module "efs" {
  source = "../../module"

  encrypted       = false
  name            = "${random_string.res_name.result}-EFSTest-minimal-options"
  security_groups = [aws_security_group.efs.id]
  vpc_id          = module.vpc.vpc_id
}
