resource "random_uuid" "resource" {}

resource "aws_efs_file_system" "resource" {
  creation_token = coalesce(var.creation_token, random_uuid.resource.id)
  kms_key_id     = var.kms_key_id
  encrypted      = var.encrypted

  tags = var.tags
}

resource "aws_efs_backup_policy" "resource" {
  file_system_id = aws_efs_file_system.resource.id

  backup_policy {
    status = upper(var.backup_policy)
  }
}

resource "aws_efs_mount_target" "resource" {
  count = length(var.subnet_ids)

  file_system_id  = aws_efs_file_system.resource.id
  subnet_id       = var.subnet_ids[count.index]
  security_groups = var.security_group_ids
}

output "id" {
  description = "The ID of the EFS file system."
  value       = aws_efs_file_system.resource.id
}

output "name" {
  description = "The name of the file system."
  value       = aws_efs_file_system.resource.name
}

output "arn" {
  description = "The ARN of the EFS file system."
  value       = aws_efs_file_system.resource.arn
}

output "dns_name" {
  description = "The DNS name of the EFS file system."
  value       = aws_efs_file_system.resource.dns_name
}

output "mount_targets" {
  description = "Map of subnet ID to mount target ID."
  value       = { for i, s in var.subnet_ids : s => aws_efs_mount_target.resource[i].id }
}
