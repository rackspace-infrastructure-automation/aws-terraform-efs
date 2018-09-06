provider "aws" {
  version = "~> 1.2"
  region  = "us-west-2"
}

module "vpc" {
  source = "github.com/rackspace-infrastructure-automation/aws-terraform-vpc_basenetwork//?ref=v0.0.2"

  vpc_name = "EFSTest-minimal-options-unencrypted-1VPC"
}

module "efs" {
  source = "github.com/rackspace-infrastructure-automation/aws-terraform-efs//?ref=<specify_version_here>"

  name      = "EFSTest-minimal-options-unencrypted"
  encrypted = "false"

  vpc_id = "${module.vpc.vpc_id}"
}
