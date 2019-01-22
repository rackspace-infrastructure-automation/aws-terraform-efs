provider "aws" {
  version = "~> 1.2"
  region  = "us-west-2"
}

module "vpc" {
  source = "git@github.com:rackspace-infrastructure-automation/aws-terraform-vpc_basenetwork//?ref=v0.0.6"

  vpc_name = "EFSTest-minimal-options-unencrypted-1VPC"
}

module "efs" {
  source = "git@github.com:rackspace-infrastructure-automation/aws-terraform-efs//?ref=v0.0.5"

  name      = "EFSTest-minimal-options-unencrypted"
  encrypted = "false"

  vpc_id = "${module.vpc.vpc_id}"
}
