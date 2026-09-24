# terraform-aws-efs

Terraform module for an EFS file system with encryption at rest and automatic
backups enabled out of the box.

## Cost

Amazon EFS bills for storage consumed and, if provisioned throughput is
configured, for that throughput. An empty file system with no
provisioned throughput carries no meaningful charge. See AWS's
[EFS pricing](https://aws.amazon.com/efs/pricing/) page for current
rates.

## Design

The file system, its backup policy, and one mount target per subnet are
bundled into this module because they are never useful apart — a file
system with no mount target is unreachable from any VPC.

**Mount targets are addressed by their position in `subnet_ids`, not by
the subnet ID itself.** Keying them by ID would read better in state,
and it does not work: Terraform has to know every `for_each` key before
it plans, and a subnet created in the same apply has no ID yet, so the
plan fails with *"the for_each set includes values derived from resource
attributes that cannot be determined until apply."* A list's length is
known even when none of its elements are, so `count` plans cleanly
against subnets built alongside the file system — which is the ordinary
case. The `mount_targets` output still maps subnet ID to mount target
ID, so nothing downstream changes.

The consequence worth knowing: **reordering or removing an entry in
`subnet_ids` shifts every later mount target's address**, and Terraform
will plan to destroy and recreate them. Append rather than insert, and
use `moved` blocks when an existing deployment has to be reshuffled.

## Usage

```hcl
module "efs" {
  source = "kn47ytv9mv/efs/aws"
}
```

Or directly from this repository:

```hcl
module "efs" {
  source = "github.com/kn47ytv9mv/terraform-aws-efs"
}
```

## Requirements

| Name | Version |
|---|---|
| terraform | >= 1.0 |
| aws | ~> 6.61 |
| random | ~> 3.9 |

## Providers

| Name | Version |
|---|---|
| aws | ~> 6.61 |
| random | ~> 3.9 |

## Inputs

| Name | Description | Default | Required |
|---|---|---|---|
| creation_token | Creation token of the EFS file system. If null, a unique token is generated. | `null` | no |
| encrypted | Whether Amazon EFS encrypts the file system at rest. | `true` | no |
| kms_key_id | The ARN of the KMS key used for encryption at rest. If null, the AWS owned key `aws/elasticfilesystem` is used. | `null` | no |
| backup_policy | Backup policy state of the file system (e.g. `'enabled'` or `'disabled'`). | `"enabled"` | no |
| subnet_ids | IDs of the subnets in which to create mount targets. If empty, no mount targets are created. | `[]` | no |
| security_group_ids | IDs of the security groups to associate with the mount targets. If null, the VPC's default security group is used. | `null` | no |
| tags | A map of tags to assign to the file system. | `null` | no |

## Outputs

| Name | Description |
|---|---|
| id | The ID of the EFS file system. |
| arn | The ARN of the EFS file system. |
| dns_name | The DNS name of the EFS file system. |
| mount_targets | Map of subnet ID to mount target ID. |
| name | The name of the file system. |

## License

MIT — see [LICENSE.md](LICENSE.md).
