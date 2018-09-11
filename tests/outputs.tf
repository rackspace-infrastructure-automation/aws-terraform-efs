#############
# EFS Outputs
#############

output "filesystem_id" {
  value       = "${module.efs.filesystem_id}"
  description = "The ID that identifies the file system"
}

output "filesystem_dns_name" {
  value       = "${module.efs.filesystem_dns_name}"
  description = "The DNS name for the filesystem"
}

##########################
# EFS Mount Target Outputs
##########################

output "mount_target_id" {
  value       = "${module.efs.mount_target_id}"
  description = "The ID of the mount target"
}

output "mount_target_dns_name" {
  value       = "${module.efs.mount_target_dns_name}"
  description = "The DNS name for the mount target in a given subnet/AZ"
}

output "mount_target_network_interface_id" {
  value       = "${module.efs.mount_target_network_interface_id}"
  description = "The ID of the network interface automatically created for the mount target"
}

#########################################
# EFS Mount Target Security Group Outputs
#########################################

output "mount_target_security_group_id" {
  value       = "${module.efs.mount_target_security_group_id}"
  description = "ID of the security group created for the EFS mount target"
}

#######################
# Conditional Resources
#######################

output "mount_target_internal_r53_record" {
  value       = "${module.efs.mount_target_internal_r53_record}"
  description = "Internal Route 53 record FQDN for the EFS mount target"
}

output "filesystem_id_ssm_parameter" {
  value       = "${module.efs.filesystem_id_ssm_parameter}"
  description = "Name of the SSM parameter containing the captured filesystem ID"
}

output "filesystem_dns_name_ssm_parameter" {
  value       = "${module.efs.filesystem_dns_name_ssm_parameter}"
  description = "Name of the SSM parameter containing the captured filesystem DNS name"
}
