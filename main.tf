/**
 * # aws-terraform-efs
 *
 * This module sets up a basic Elastic File System on AWS for an account in a specific region.
 *
 * ## Basic Usage
 *
 * ```HCL
 * module "efs" {
 *   source = "git@github.com:rackspace-infrastructure-automation/aws-terraform-efs//?ref=v0.0.7"
 *
 *   encrypted       = "false"
 *   name            = "EFSTest-minimal-options-unencrypted"
 *   security_groups = ["${aws_security_group.efs.id}"]
 *   vpc_id          = "${module.vpc.vpc_id}"
 * }
 * ```
 *
 * Full working references are available at [examples](examples)
 * ## Other TF Modules Used
 * Using [aws-terraform-cloudwatch_alarm](https://github.com/rackspace-infrastructure-automation/aws-terraform-cloudwatch_alarm) to create the following CloudWatch Alarms:
 * 	- efs_burst_credits
 */

data "aws_region" "current_region" {
}

data "aws_caller_identity" "current_account" {
}

locals {
  base_tags = {
    ServiceProvider = "Rackspace"
    Environment     = var.environment
  }
}

resource "aws_efs_file_system" "fs" {
  creation_token                  = var.name
  performance_mode                = var.performance_mode
  provisioned_throughput_in_mibps = var.provisioned_throughput_in_mibps
  throughput_mode                 = var.provisioned_throughput_in_mibps == 0 ? "bursting" : "provisioned"
  encrypted                       = var.encrypted
  kms_key_id                      = var.kms_key_arn

  tags = merge(
    local.base_tags,
    {
      "Name" = var.name
    },
    var.custom_tags,
  )
}

resource "aws_efs_mount_target" "mount" {
  count = var.mount_target_subnets_count

  file_system_id  = aws_efs_file_system.fs.id
  subnet_id       = element(var.mount_target_subnets, count.index)
  security_groups = var.security_groups
}

module "efs_burst_credits" {
  source = "git@github.com:rackspace-infrastructure-automation/aws-terraform-cloudwatch_alarm//?ref=v0.0.1"

  alarm_description        = "EFS Burst Credits have dropped below ${var.cw_burst_credit_threshold} for ${var.cw_burst_credit_period} periods."
  alarm_name               = "${var.name}-EFSBurstCredits"
  comparison_operator      = "LessThanThreshold"
  evaluation_periods       = var.cw_burst_credit_period
  metric_name              = "BurstCreditBalance"
  namespace                = "AWS/EFS"
  notification_topic       = var.notification_topic
  period                   = "3600"
  rackspace_alarms_enabled = var.rackspace_alarms_enabled
  rackspace_managed        = var.rackspace_managed
  severity                 = "emergency"
  statistic                = "Minimum"
  threshold                = var.cw_burst_credit_threshold

  dimensions = [
    {
      FileSystemId = aws_efs_file_system.fs.id
    },
  ]
}

resource "aws_route53_record" "efs" {
  count = var.create_internal_dns_record ? 1 : 0

  zone_id = var.internal_zone_id
  name    = var.internal_record_name != "" ? var.internal_record_name : "efs-${var.name}-${var.environment}"
  type    = "CNAME"
  ttl     = "300"
  records = [aws_efs_file_system.fs.dns_name]
}

resource "aws_ssm_parameter" "efs_filesystem_id" {
  count = var.create_parameter_store_entries ? 1 : 0

  name  = "/${var.environment}/${var.name}/efs/filesystem_id"
  type  = "String"
  value = aws_efs_file_system.fs.id
}

resource "aws_ssm_parameter" "efs_fqdn" {
  count = var.create_parameter_store_entries ? 1 : 0

  name  = "/${var.environment}/${var.name}/efs/fqdn"
  type  = "String"
  value = aws_efs_file_system.fs.dns_name
}

