variable "creation_token" {
  default     = null
  description = "Creation token of the EFS file system. If null, a unique token is generated."
}

variable "encrypted" {
  default     = true
  description = "Whether Amazon EFS encrypts the file system at rest."
}

variable "kms_key_id" {
  default     = null
  description = "The ARN of the KMS key used for encryption at rest. If null, the AWS owned key 'aws/elasticfilesystem' is used."
}

variable "backup_policy" {
  default     = "enabled"
  description = "Backup policy state of the file system (e.g. 'enabled' or 'disabled')."
}

variable "subnet_ids" {
  default     = []
  description = "IDs of the subnets in which to create mount targets. If empty, no mount targets are created."
}

variable "security_group_ids" {
  default     = null
  description = "IDs of the security groups to associate with the mount targets. If null, the VPC's default security group is used."
}

variable "tags" {
  default     = null
  description = "A map of tags to assign to the file system."
}
