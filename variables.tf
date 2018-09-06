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
