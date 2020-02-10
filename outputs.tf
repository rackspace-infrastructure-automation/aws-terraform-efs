output "filesystem_arn" {
  value       = aws_efs_file_system.fs.arn
  description = "The ARN for the filesystem"
}

output "filesystem_dns_name" {
  value       = aws_efs_file_system.fs.dns_name
  description = "The DNS name for the filesystem"
}

output "filesystem_dns_name_ssm_parameter" {
  value       = aws_ssm_parameter.efs_fqdn.*.name
  description = "Name of the SSM parameter containing the captured filesystem DNS name"
}

output "filesystem_id" {
  value       = aws_efs_file_system.fs.id
  description = "The ID that identifies the file system"
}

output "filesystem_id_ssm_parameter" {
  value       = aws_ssm_parameter.efs_filesystem_id.*.name
  description = "Name of the SSM parameter containing the captured filesystem ID"
}

output "mount_target_dns_name" {
  value       = aws_efs_mount_target.mount.*.dns_name
  description = "The DNS name for the mount target in a given subnet/AZ"
}

output "mount_target_id" {
  value       = aws_efs_mount_target.mount.*.id
  description = "The ID of the mount target"
}

output "mount_target_internal_r53_record" {
  value       = aws_route53_record.efs.*.fqdn
  description = "Internal Route 53 record FQDN for the EFS mount target"
}

output "mount_target_network_interface_id" {
  value       = aws_efs_mount_target.mount.*.network_interface_id
  description = "The ID of the network interface automatically created for the mount target"
}
