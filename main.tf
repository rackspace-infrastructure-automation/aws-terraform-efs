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

resource "aws_efs_mount_target" "mnt" {
  count = "${var.mount_target_subnets_count}"

  file_system_id  = "${aws_efs_file_system.fs.id}"
  subnet_id       = "${element(var.mount_target_subnets, count.index)}"
  security_groups = ["${aws_security_group.mnt.id}"]
}

resource "aws_security_group" "mnt" {
  name        = "${var.name}"
  description = "Security group dedicated to the ${var.name} EFS mount target."
  vpc_id      = "${var.vpc_id}"

  tags = "${merge(local.base_tags, map("Name", var.name), var.custom_tags)}"
}

resource "aws_security_group_rule" "mnt_ingress" {
  count = "${var.mnt_ingress_security_groups_count}"

  type                     = "ingress"
  protocol                 = "tcp"
  from_port                = 2049
  to_port                  = 2049
  security_group_id        = "${aws_security_group.mnt.id}"
  source_security_group_id = "${element(var.mnt_ingress_security_groups, count.index)}"
}

resource "aws_security_group_rule" "mnt_egress" {
  type              = "egress"
  protocol          = -1
  from_port         = 0
  to_port           = 0
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = "${aws_security_group.mnt.id}"
}
