#############
# EFS Outputs
#############

output "filesystem_id" {
  value       = "${aws_efs_file_system.fs.id}"
  description = "The ID that identifies the file system"
}

output "filesystem_dns_name" {
  value       = "${aws_efs_file_system.fs.dns_name}"
  description = "The DNS name for the filesystem"
}

##########################
# EFS Mount Target Outputs
##########################

output "mount_target_id" {
  value       = "${aws_efs_mount_target.mnt.*.id}"
  description = "The ID of the mount target"
}

output "mount_target_dns_name" {
  value       = "${aws_efs_mount_target.mnt.*.dns_name}"
  description = "The DNS name for the mount target in a given subnet/AZ"
}

output "mount_target_network_interface_id" {
  value       = "${aws_efs_mount_target.mnt.*.network_interface_id}"
  description = "The ID of the network interface automatically created for the mount target"
}

#########################################
# EFS Mount Target Security Group Outputs
#########################################

output "mount_target_security_group_id" {
  value       = "${aws_security_group.mnt.id}"
  description = "ID of the security group created for the EFS mount target"
}
