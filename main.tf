locals {
  base_tags = {
    ServiceProvider = "Rackspace"
    Environment     = "${var.environment}"
  }
}

resource "aws_efs_file_system" "fs" {
  creation_token                  = "${var.name}"
  performance_mode                = "${var.performance_mode}"
  provisioned_throughput_in_mibps = "${var.provisioned_throughput_in_mibps}"
  throughput_mode                 = "${var.provisioned_throughput_in_mibps == 0 ? "bursting" : "provisioned"}"
  encrypted                       = "${var.encrypted}"
  kms_key_id                      = "${var.kms_key_arn}"

  tags = "${merge(local.base_tags, map("Name", var.name), var.custom_tags)}"
}
