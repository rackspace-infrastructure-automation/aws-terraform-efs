> [!CAUTION]
> This project is end of life. This repo will be deleted on June 2nd 2025.


# aws-terraform-efs

This module sets up a basic Elastic File System on AWS for an account in a specific region.

## Basic Usage

```HCL
module "efs" {
  source = "git@github.com:rackspace-infrastructure-automation/aws-terraform-efs//?ref=v0.0.7"

  encrypted       = "false"
  name            = "EFSTest-minimal-options-unencrypted"
  security_groups = ["${aws_security_group.efs.id}"]
  vpc_id          = "${module.vpc.vpc_id}"
}
```

Full working references are available at [examples](examples)
## Other TF Modules Used  
Using [aws-terraform-cloudwatch\_alarm](https://github.com/rackspace-infrastructure-automation/aws-terraform-cloudwatch_alarm) to create the following CloudWatch Alarms:
	- efs\_burst\_credits

## Terraform 0.12 upgrade

Several changes were required while adding terraform 0.12 compatibility.  The following changes should be  
made when upgrading from a previous release to version 0.12.0 or higher.

### Module variables

The following module variables were updated to better meet current Rackspace style guides:

- `custom_tags` -> `tags`
- `create_internal_dns_record` -> `create_internal_zone_record`

## Requirements

| Name | Version |
|------|---------|
| terraform | >= 0.12 |
| aws | >= 2.7.0 |

## Providers

| Name | Version |
|------|---------|
| aws | >= 2.7.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| efs_burst_credits | git@github.com:rackspace-infrastructure-automation/aws-terraform-cloudwatch_alarm//?ref=v0.12.6 |  |

## Resources

| Name |
|------|
| [aws_caller_identity](https://registry.terraform.io/providers/hashicorp/aws/2.7.0/docs/data-sources/caller_identity) |
| [aws_efs_file_system](https://registry.terraform.io/providers/hashicorp/aws/2.7.0/docs/resources/efs_file_system) |
| [aws_efs_mount_target](https://registry.terraform.io/providers/hashicorp/aws/2.7.0/docs/resources/efs_mount_target) |
| [aws_region](https://registry.terraform.io/providers/hashicorp/aws/2.7.0/docs/data-sources/region) |
| [aws_route53_record](https://registry.terraform.io/providers/hashicorp/aws/2.7.0/docs/resources/route53_record) |
| [aws_ssm_parameter](https://registry.terraform.io/providers/hashicorp/aws/2.7.0/docs/resources/ssm_parameter) |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| create\_internal\_zone\_record | Create Route 53 internal zone record for the resource Default is \"false\". | `bool` | `false` | no |
| create\_parameter\_store\_entries | Whether or not to create EC2 Parameter Store entries to expose the EFS DNS name and Filesystem ID. | `bool` | `true` | no |
| cw\_burst\_credit\_period | The number of periods over which the EFS Burst Credit level is compared to the specified threshold. | `number` | `12` | no |
| cw\_burst\_credit\_threshold | The minimum EFS Burst Credit level before generating an alarm. | `number` | `1000000000000` | no |
| encrypted | Whether or not the disk should be encrypted. | `bool` | `true` | no |
| environment | A field used to set the Environment tag on created resources. | `string` | `"Development"` | no |
| internal\_record\_name | Record Name for the new Resource Record in the Internal Hosted Zone. | `string` | `""` | no |
| internal\_zone\_id | The zone id for the internal records i.e. Z2QHD5YD1WXE9M | `string` | `""` | no |
| kms\_key\_arn | The ARN for the KMS key to use for encrypting the disk. If specified, `encrypted` must be set to \"true\"`. If left<br>blank and `encrypted` is set to \"true\", Terraform will use the default `aws/elasticfilesystem` KMS key.<br>` | `string` | `""` | no |
| mount\_target\_subnets | Subnets in which the EFS mount target will be created. | `list(string)` | `[]` | no |
| mount\_target\_subnets\_count | Number of `mount_target_subnets` (workaround for `count` not working fully within modules) | `number` | `0` | no |
| name | A Name prefix to use for created resources | `string` | n/a | yes |
| notification\_topic | The SNS topic to use for customer notifications. | `list(string)` | `[]` | no |
| performance\_mode | The file system performance mode. Can be either "generalPurpose" or "maxIO". | `string` | `"generalPurpose"` | no |
| provisioned\_throughput\_in\_mibps | The throughput, measured in MiB/s, that you want to provision for the file system.<br>**NOTE**: Setting a non-zero value will automatically enable \"provisioned\" throughput mode. To use \"bursting\"<br>`throughput mode, leave this value set to \"0\".<br>` | `number` | `0` | no |
| rackspace\_alarms\_enabled | Specifies whether alarms will create a Rackspace ticket. Ignored if rackspace\_managed is set to false. | `bool` | `false` | no |
| rackspace\_managed | Boolean parameter controlling if instance will be fully managed by Rackspace support teams, created CloudWatch alarms that generate tickets, and utilize Rackspace managed SSM documents. | `bool` | `true` | no |
| security\_groups | List of security groups to apply to created resources. | `list(string)` | n/a | yes |
| tags | A mapping of tags applied to resources created by the module | `map(string)` | `{}` | no |
| vpc\_id | The VPC ID where resources should be created. | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| filesystem\_arn | The ARN for the filesystem |
| filesystem\_dns\_name | The DNS name for the filesystem |
| filesystem\_dns\_name\_ssm\_parameter | Name of the SSM parameter containing the captured filesystem DNS name |
| filesystem\_id | The ID that identifies the file system |
| filesystem\_id\_ssm\_parameter | Name of the SSM parameter containing the captured filesystem ID |
| mount\_target\_dns\_name | The DNS name for the mount target in a given subnet/AZ |
| mount\_target\_id | The ID of the mount target |
| mount\_target\_internal\_r53\_record | Internal Route 53 record FQDN for the EFS mount target |
| mount\_target\_network\_interface\_id | The ID of the network interface automatically created for the mount target |
