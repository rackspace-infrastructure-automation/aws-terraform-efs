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

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|:----:|:-----:|:-----:|
| create\_internal\_dns\_record | Whether or not to create a custom, internal DNS record for the EFS endpoint's generated DNS name. If \"true\", the `internal_zone_id` MUST be provided, and a specific `internal_record_name` MAY be provided. Default is \"false\". | string | `"false"` | no |
| create\_parameter\_store\_entries | Whether or not to create EC2 Parameter Store entries to expose the EFS DNS name and Filesystem ID. | string | `"true"` | no |
| custom\_tags | Optional tags to be applied on top of the base tags on all resources | map | `<map>` | no |
| cw\_burst\_credit\_period | The number of periods over which the EFS Burst Credit level is compared to the specified threshold. | string | `"12"` | no |
| cw\_burst\_credit\_threshold | The minimum EFS Burst Credit level before generating an alarm. | string | `"1000000000000"` | no |
| encrypted | Whether or not the disk should be encrypted. | string | `"true"` | no |
| environment | Application environment for which this network is being created. e.g. Development/Production | string | `"Development"` | no |
| internal\_record\_name | If `internal_zone_id` is provided, Terraform will create a DNS record using the provided `internal_record_name` as the subdomain. If no `internal_record_name` is provided, the convention \"efs-<name>-<environment>\" will be used. | string | `""` | no |
| internal\_zone\_id | A Route 53 Internal Hosted Zone ID. If provided, a DNS record will be created for the EFS endpoint's DNS name, which can be used to reference the mount target. | string | `""` | no |
| kms\_key\_arn | The ARN for the KMS key to use for encrypting the disk. If specified, `encrypted` must be set to \"true\"`. If left blank and `encrypted` is set to \"true\", Terraform will use the default `aws/elasticfilesystem` KMS key. | string | `""` | no |
| mount\_target\_subnets | Subnets in which the EFS mount target will be created. | list | `<list>` | no |
| mount\_target\_subnets\_count | Number of `mount_target_subnets` (workaround for `count` not working fully within modules) | string | `"0"` | no |
| name | A unique name (a maximum of 64 characters are allowed) used as reference when creating the Elastic File System to ensure idempotent file system creation. | string | n/a | yes |
| notification\_topic | List of SNS Topic ARNs to use for customer notifications. | list | `<list>` | no |
| performance\_mode | The file system performance mode. Can be either "generalPurpose" or "maxIO". | string | `"generalPurpose"` | no |
| provisioned\_throughput\_in\_mibps | The throughput, measured in MiB/s, that you want to provision for the file system. **NOTE**: Setting a non-zero value will automatically enable \"provisioned\" throughput mode. To use \"bursting\" `throughput mode, leave this value set to \"0\". | string | `"0"` | no |
| rackspace\_alarms\_enabled | Specifies whether alarms will create a Rackspace ticket.  Ignored if rackspace_managed is set to false. | string | `"false"` | no |
| rackspace\_managed | Boolean parameter controlling if instance will be fully managed by Rackspace support teams, created CloudWatch alarms that generate tickets, and utilize Rackspace managed SSM documents. | string | `"true"` | no |
| security\_groups | A list of EC2 security groups to assign to this resource | list | n/a | yes |
| vpc\_id | The VPC ID. | string | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| filesystem\_dns\_name | The DNS name for the filesystem |
| filesystem\_dns\_name\_ssm\_parameter | Name of the SSM parameter containing the captured filesystem DNS name |
| filesystem\_id | The ID that identifies the file system |
| filesystem\_id\_ssm\_parameter | Name of the SSM parameter containing the captured filesystem ID |
| mount\_target\_dns\_name | The DNS name for the mount target in a given subnet/AZ |
| mount\_target\_id | The ID of the mount target |
| mount\_target\_internal\_r53\_record | Internal Route 53 record FQDN for the EFS mount target |
| mount\_target\_network\_interface\_id | The ID of the network interface automatically created for the mount target |

