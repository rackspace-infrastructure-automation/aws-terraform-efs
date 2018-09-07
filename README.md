# EFS

## Description

This module sets up a basic Elastic File System on AWS for an account in a specific region.

## Default Resources

By default, only the `name` and `vpc_id` are required to be set in order to create the filesystem; however, the `mount_target_subnets` and `mnt_ingress_security_groups` need to be configured in order for the filesystem to actually be usable.

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|:----:|:-----:|:-----:|
| custom_tags | Optional tags to be applied on top of the base tags on all resources | map | `<map>` | no |
| encrypted | Whether or not the disk should be encrypted. | string | `true` | no |
| environment | Application environment for which this network is being created. e.g. Development/Production | string | `Development` | no |
| kms_key_arn | The ARN for the KMS key to use for encrypting the disk. If specified, `encrypted` must be set to \"true\"`. If left blank and `encrypted` is set to \"true\", Terraform will use the default `aws/elasticfilesystem` KMS key. | string | `` | no |
| mnt_ingress_security_groups | List of security group IDs that should be granted ingress for the EFS mount target. | list | `<list>` | no |
| mnt_ingress_security_groups_count | Number of `mnt_ingress_security_groups` (workaround for `count` not working fully within modules) | string | `0` | no |
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
| filesystem_id | The ID that identifies the file system |
| mount_target_dns_name | The DNS name for the mount target in a given subnet/AZ |
| mount_target_id | The ID of the mount target |
| mount_target_network_interface_id | The ID of the network interface automatically created for the mount target |
| mount_target_security_group_id | ID of the security group created for the EFS mount target |

## Examples

* [Minimal options, no encryption](examples/minimal-options-unencrypted.tf)
* [With all options](examples/with-all-options.tf)
