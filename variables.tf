variable "create_internal_zone_record" {
  description = <<EOF
Create Route 53 internal zone record for the resource Default is \"false\".
EOF

  type    = string
  default = "false"
}

variable "create_parameter_store_entries" {
  description = "Whether or not to create EC2 Parameter Store entries to expose the EFS DNS name and Filesystem ID."
  type        = string
  default     = "true"
}

variable "custom_tags" {
  description = "Optional tags to be applied on top of the base tags on all resources."
  type        = map(string)
  default     = {}
}

variable "cw_burst_credit_period" {
  description = "The number of periods over which the EFS Burst Credit level is compared to the specified threshold."
  type        = string
  default     = "12"
}

variable "cw_burst_credit_threshold" {
  description = "The minimum EFS Burst Credit level before generating an alarm."
  type        = string
  default     = "1000000000000"
}

variable "encrypted" {
  description = "Whether or not the disk should be encrypted."
  type        = string
  default     = "true"
}

variable "environment" {
  description = "A field used to set the Environment tag on created resources."
  type        = string
  default     = "Development"
}

variable "internal_zone_id" {
  description = <<EOF
The zone id for the internal records i.e. Z2QHD5YD1WXE9M
EOF

  type    = string
  default = ""
}

variable "internal_record_name" {
  description = <<EOF
Record Name for the new Resource Record in the Internal Hosted Zone.
EOF


  type    = string
  default = ""
}

variable "kms_key_arn" {
  description = <<EOF
The ARN for the KMS key to use for encrypting the disk. If specified, `encrypted` must be set to \"true\"`. If left
blank and `encrypted` is set to \"true\", Terraform will use the default `aws/elasticfilesystem` KMS key.
EOF


  type    = string
  default = ""
}

variable "mount_target_subnets" {
  description = "Subnets in which the EFS mount target will be created."
  type        = list(string)
  default     = []
}

variable "mount_target_subnets_count" {
  description = "Number of `mount_target_subnets` (workaround for `count` not working fully within modules)"
  type        = number
  default     = 0
}

variable "name" {
  description = <<EOF
A Name prefix to use for created resources
EOF


  type = string
}

variable "notification_topic" {
  description = "The SNS topic to use for customer notifications."
  type        = list(string)
  default     = []
}

variable "performance_mode" {
  description = "The file system performance mode. Can be either \"generalPurpose\" or \"maxIO\"."
  type        = string
  default     = "generalPurpose"
}

variable "provisioned_throughput_in_mibps" {
  description = <<EOF
The throughput, measured in MiB/s, that you want to provision for the file system.
**NOTE**: Setting a non-zero value will automatically enable \"provisioned\" throughput mode. To use \"bursting\"
`throughput mode, leave this value set to \"0\".
EOF


  type    = number
  default = 0
}

variable "rackspace_alarms_enabled" {
  description = "Specifies whether alarms will create a Rackspace ticket. Ignored if rackspace_managed is set to false."
  type        = bool
  default     = false
}

variable "rackspace_managed" {
  description = "Boolean parameter controlling if instance will be fully managed by Rackspace support teams, created CloudWatch alarms that generate tickets, and utilize Rackspace managed SSM documents."
  type        = bool
  default     = true
}

variable "security_groups" {
  description = "List of security groups to apply to created resources."
  type        = list(string)
}

variable "vpc_id" {
  description = "The VPC ID where resources should be created."
  type        = string
}
