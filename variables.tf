#################
# General Options
#################

variable "environment" {
  description = "Application environment for which this network is being created. e.g. Development/Production"
  type        = "string"
  default     = "Development"
}

variable "custom_tags" {
  description = "Optional tags to be applied on top of the base tags on all resources"
  type        = "map"
  default     = {}
}

##################
# EFS Core Options
##################

variable "name" {
  description = <<EOF
A unique name (a maximum of 64 characters are allowed) used as reference when creating the Elastic File System to ensure
idempotent file system creation.
EOF

  type = "string"
}

variable "performance_mode" {
  description = "The file system performance mode. Can be either \"generalPurpose\" or \"maxIO\"."
  type        = "string"
  default     = "generalPurpose"
}

variable "provisioned_throughput_in_mibps" {
  description = <<EOF
The throughput, measured in MiB/s, that you want to provision for the file system.
**NOTE**: Setting a non-zero value will automatically enable \"provisioned\" throughput mode. To use \"bursting\"
`throughput mode, leave this value set to \"0\".
EOF

  type    = "string"
  default = "0"
}

variable "encrypted" {
  description = "Whether or not the disk should be encrypted."
  type        = "string"
  default     = "true"
}

variable "kms_key_arn" {
  description = <<EOF
The ARN for the KMS key to use for encrypting the disk. If specified, `encrypted` must be set to \"true\"`. If left
blank and `encrypted` is set to \"true\", Terraform will use the default `aws/elasticfilesystem` KMS key.
EOF

  type    = "string"
  default = ""
}

###############################
# EFS Mount Target Core Options
###############################

variable "mount_target_subnets" {
  description = "Subnets in which the EFS mount target will be created."
  type        = "list"
  default     = []
}

variable "mount_target_subnets_count" {
  description = "Number of `mount_target_subnets` (workaround for `count` not working fully within modules)"
  type        = "string"
  default     = "0"
}

variable "vpc_id" {
  description = "The VPC ID."
  type        = "string"
}

variable "mnt_ingress_security_groups" {
  description = "List of security group IDs that should be granted ingress for the EFS mount target."
  type        = "list"
  default     = []
}

variable "mnt_ingress_security_groups_count" {
  description = "Number of `mnt_ingress_security_groups` (workaround for `count` not working fully within modules)"
  type        = "string"
  default     = "0"
}

################################
# CloudWatch Alarms Core Options
################################

variable "cw_burst_credit_period" {
  description = "The number of periods over which the EFS Burst Credit level is compared to the specified threshold."
  type        = "string"
  default     = "12"
}

variable "cw_burst_credit_threshold" {
  description = "The minimum EFS Burst Credit level before generating an alarm."
  type        = "string"
  default     = "1000000000000"
}

variable "rackspace_managed" {
  description = <<EOF
Whether or not the filesystem will be managed by Rackspace support teams and create CloudWatch alarms that generate
support tickets.
EOF

  type    = "string"
  default = "true"
}

variable "custom_alarm_sns_topic" {
  description = "If not Rackspace managed, you can use custom SNS topics to send the Alarm actions to."
  type        = "list"
  default     = []
}

variable "custom_ok_sns_topic" {
  description = "If not Rackspace managed, you can use custom SNS topics to send the OK actions to."
  type        = "list"
  default     = []
}

#######################
# Conditional Resources
#######################

variable "create_parameter_store_entries" {
  description = "Whether or not to create EC2 Parameter Store entries to expose the EFS DNS name and Filesystem ID."
  type        = "string"
  default     = "true"
}

variable "create_internal_dns_record" {
  description = <<EOF
Whether or not to create a custom, internal DNS record for the EFS endpoint's generated DNS name. If \"true\", the
`internal_zone_id` MUST be provided, and a specific `internal_record_name` MAY be provided. Default is \"false\".
EOF

  type    = "string"
  default = "false"
}

variable "internal_zone_id" {
  description = <<EOF
A Route 53 Internal Hosted Zone ID. If provided, a DNS record will be created for the EFS endpoint's DNS name, which
can be used to reference the mount target.
EOF

  type    = "string"
  default = ""
}

variable "internal_record_name" {
  description = <<EOF
If `internal_zone_id` is provided, Terraform will create a DNS record using the provided `internal_record_name` as the
subdomain. If no `internal_record_name` is provided, the convention \"efs-<name>-<environment>\" will be used.
EOF

  type    = "string"
  default = ""
}
