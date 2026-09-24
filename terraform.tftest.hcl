mock_provider "aws" {
}

run "default_config_creates_file_system_and_backup_policy" {
  command = plan

  assert {
    condition     = aws_efs_file_system.resource.encrypted == true
    error_message = "encrypted should default to true."
  }

  assert {
    condition     = aws_efs_backup_policy.resource.backup_policy[0].status == "ENABLED"
    error_message = "backup_policy should default to 'enabled', uppercased for the AWS argument."
  }

  assert {
    condition     = length(aws_efs_mount_target.resource) == 0
    error_message = "No subnet_ids given, so no mount targets should be created."
  }
}

run "backup_policy_disabled_uppercased" {
  command = plan

  variables {
    backup_policy = "disabled"
  }

  assert {
    condition     = aws_efs_backup_policy.resource.backup_policy[0].status == "DISABLED"
    error_message = "backup_policy = 'disabled' should uppercase to 'DISABLED'."
  }
}

run "mount_targets_created_for_each_subnet" {
  command = plan

  variables {
    subnet_ids         = ["subnet-aaaaaaaa", "subnet-bbbbbbbb"]
    security_group_ids = ["sg-12345678"]
  }

  assert {
    condition     = length(aws_efs_mount_target.resource) == 2
    error_message = "One mount target should be created per given subnet ID."
  }

  assert {
    condition     = aws_efs_mount_target.resource[0].subnet_id == "subnet-aaaaaaaa"
    error_message = "Each mount target should target the subnet ID at its own position in subnet_ids."
  }

  assert {
    condition     = aws_efs_mount_target.resource[0].security_groups == toset(["sg-12345678"])
    error_message = "security_group_ids should be passed through to every mount target."
  }
}

run "creation_token_and_kms_key_id_passthrough" {
  command = plan

  variables {
    creation_token = "my-fixed-token"
    kms_key_id     = "arn:aws:kms:us-east-1:123456789012:key/abcd1234-a123-456a-a12b-a123b4cd56ef"
  }

  assert {
    condition     = aws_efs_file_system.resource.creation_token == "my-fixed-token"
    error_message = "An explicit creation_token should be used as-is."
  }

  assert {
    condition     = aws_efs_file_system.resource.kms_key_id == "arn:aws:kms:us-east-1:123456789012:key/abcd1234-a123-456a-a12b-a123b4cd56ef"
    error_message = "kms_key_id should be passed through to the file system."
  }
}

run "creation_token_generated_when_unset" {
  command = apply

  assert {
    condition     = aws_efs_file_system.resource.creation_token == random_uuid.resource.id
    error_message = "With creation_token unset, the file system should use the generated random_uuid."
  }
}

run "readme_default_minimal" {
  command = plan
}
