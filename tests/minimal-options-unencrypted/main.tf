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

module "efs" {
  source = "../../module"

  name      = "EFSTest-minimal-options-${random_string.res_name.result}"
  encrypted = "false"

  vpc_id = "${module.vpc.vpc_id}"
}
