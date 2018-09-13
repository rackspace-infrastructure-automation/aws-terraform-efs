# EFS

## Description

This module sets up a basic Elastic File System on AWS for an account in a specific region.

## Default Resources

By default, only the `name` and `vpc_id` are required to be set in order to create the filesystem; however, the `mount_target_subnets` and `mount_ingress_security_groups` need to be configured in order for the filesystem to actually be usable.

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|:----:|:-----:|:-----:|
| create_internal_dns_record | Whether or not to create a custom, internal DNS record for the EFS endpoint's generated DNS name. If \"true\", the `internal_zone_id` MUST be provided, and a specific `internal_record_name` MAY be provided. Default is \"false\". | string | `false` | no |
| create_parameter_store_entries | Whether or not to create EC2 Parameter Store entries to expose the EFS DNS name and Filesystem ID. | string | `true` | no |
| custom_tags | Optional tags to be applied on top of the base tags on all resources | map | `<map>` | no |
| encrypted | Whether or not the disk should be encrypted. | string | `true` | no |
| environment | Application environment for which this network is being created. e.g. Development/Production | string | `Development` | no |
| internal_record_name | If `internal_zone_id` is provided, Terraform will create a DNS record using the provided `internal_record_name` as the subdomain. If no `internal_record_name` is provided, the convention \"efs-<name>-<environment>\" will be used. | string | `` | no |
| internal_zone_id | A Route 53 Internal Hosted Zone ID. If provided, a DNS record will be created for the EFS endpoint's DNS name, which can be used to reference the mount target. | string | `` | no |
| kms_key_arn | The ARN for the KMS key to use for encrypting the disk. If specified, `encrypted` must be set to \"true\"`. If left blank and `encrypted` is set to \"true\", Terraform will use the default `aws/elasticfilesystem` KMS key. | string | `` | no |
| mount_ingress_security_groups | List of security group IDs that should be granted ingress for the EFS mount target. | list | `<list>` | no |
| mount_ingress_security_groups_count | Number of `mount_ingress_security_groups` (workaround for `count` not working fully within modules) | string | `0` | no |
| mount_target_subnets | Subnets in which the EFS mount target will be created. | list | `<list>` | no |
| mount_target_subnets_count | Number of `mount_target_subnets` (workaround for `count` not working fully within modules) | string | `0` | no |
| name | A unique name (a maximum of 64 characters are allowed) used as reference when creating the Elastic File System to ensure idempotent file system creation. | string | - | yes |
| performance_mode | The file system performance mode. Can be either "generalPurpose" or "maxIO". | string | `generalPurpose` | no |
| provisioned_throughput_in_mibps | The throughput, measured in MiB/s, that you want to provision for the file system. **NOTE**: Setting a non-zero value will automatically enable \"provisioned\" throughput mode. To use \"bursting\" `throughput mode, leave this value set to \"0\". | string | `0` | no |
| vpc_id | The VPC ID. | string | - | yes |

## Outputs

| Name | Description |
|------|-------------|
| filesystem_dns_name | The DNS name for the filesystem |
| filesystem_dns_name_ssm_parameter | Name of the SSM parameter containing the captured filesystem DNS name |
| filesystem_id | The ID that identifies the file system |
| filesystem_id_ssm_parameter | Name of the SSM parameter containing the captured filesystem ID |
| mount_target_dns_name | The DNS name for the mount target in a given subnet/AZ |
| mount_target_id | The ID of the mount target |
| mount_target_internal_r53_record | Internal Route 53 record FQDN for the EFS mount target |
| mount_target_network_interface_id | The ID of the network interface automatically created for the mount target |
| mount_target_security_group_id | ID of the security group created for the EFS mount target |

## Examples

* [Minimal options, no encryption](examples/minimal-options-unencrypted.tf)
* [With all options](examples/with-all-options.tf)
