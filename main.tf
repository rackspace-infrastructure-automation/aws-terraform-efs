data "aws_region" "current_region" {}
data "aws_caller_identity" "current_account" {}

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

locals {
  sns_topic = "arn:aws:sns:${data.aws_region.current_region.name}:${data.aws_caller_identity.current_account.account_id}:rackspace-support-emergency"

  alarm_action_config = "${var.rackspace_managed ? "managed":"unmanaged"}"

  alarm_actions = {
    managed = ["${local.sns_topic}"]

    unmanaged = "${var.custom_alarm_sns_topic}"
  }

  ok_action_config = "${var.rackspace_managed ? "managed":"unmanaged"}"

  ok_actions = {
    managed = ["${local.sns_topic}"]

    unmanaged = "${var.custom_ok_sns_topic}"
  }

  alarm_setting = "${local.alarm_actions[local.alarm_action_config]}"
  ok_setting    = "${local.ok_actions[local.ok_action_config]}"
}

resource "aws_cloudwatch_metric_alarm" "efs_burst_credits" {
  alarm_name          = "EFSBurstCredits"
  alarm_description   = "EFS Burst Credits have dropped below ${var.cw_burst_credit_threshold} for ${var.cw_burst_credit_period} periods."
  namespace           = "AWS/EFS"
  period              = "3600"
  comparison_operator = "LessThanThreshold"
  statistic           = "Minimum"
  threshold           = "${var.cw_burst_credit_threshold}"
  metric_name         = "BurstCreditBalance"
  evaluation_periods  = "${var.cw_burst_credit_period}"
  ok_actions          = ["${local.ok_setting}"]
  alarm_actions       = ["${local.alarm_setting}"]

  dimensions {
    FileSystemId = "${aws_efs_file_system.fs.id}"
  }
}

resource "aws_route53_record" "efs" {
  count = "${var.create_internal_dns_record ? 1 : 0}"

  zone_id = "${var.internal_zone_id}"
  name    = "${var.internal_record_name != "" ? var.internal_record_name : "efs-${var.name}-${var.environment}"}"
  type    = "CNAME"
  ttl     = "300"
  records = ["${aws_efs_file_system.fs.dns_name}"]
}

resource "aws_ssm_parameter" "efs_filesystem_id" {
  count = "${var.create_parameter_store_entries ? 1 : 0}"

  name  = "/${var.environment}/${var.name}/efs/filesystem_id"
  type  = "String"
  value = "${aws_efs_file_system.fs.id}"
}

resource "aws_ssm_parameter" "efs_fqdn" {
  count = "${var.create_parameter_store_entries ? 1 : 0}"

  name  = "/${var.environment}/${var.name}/efs/fqdn"
  type  = "String"
  value = "${aws_efs_file_system.fs.dns_name}"
}
