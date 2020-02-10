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

  vpc_name = "EFSTest-minimal-options-${random_string.res_name.result}"
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

module "efs" {
  source = "../../module"

  name      = "EFSTest-minimal-options-${random_string.res_name.result}"
  encrypted = "false"

  security_groups = [aws_security_group.efs.id]
  vpc_id          = module.vpc.vpc_id
}
