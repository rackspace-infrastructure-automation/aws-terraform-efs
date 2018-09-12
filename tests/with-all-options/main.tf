provider "aws" {
  version = "~> 1.2"
  region  = "us-west-2"
}

module "vpc" {
  source = "github.com/rackspace-infrastructure-automation/aws-terraform-vpc_basenetwork//?ref=v0.0.2"

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

module "efs" {
  source = "../../module"

  name                            = "EFSTest-with-all-options"
  performance_mode                = "maxIO"
  provisioned_throughput_in_mibps = "1"
  encrypted                       = "true"
  kms_key_arn                     = "${aws_kms_key.efs-test-with-all-options.arn}"

  custom_tags = {
    foo = "bar"
  }

  vpc_id = "${module.vpc.vpc_id}"

  mnt_ingress_security_groups       = ["${module.vpc.default_sg}"]
  mnt_ingress_security_groups_count = 1

  mount_target_subnets       = ["${module.vpc.private_subnets}"]
  mount_target_subnets_count = 2

  create_parameter_store_entries = "false"
  create_internal_dns_record     = "true"
  internal_zone_id               = "${aws_route53_zone.internal.zone_id}"
}
