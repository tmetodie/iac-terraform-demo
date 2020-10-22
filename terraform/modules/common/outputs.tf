output "encryption_key" {
  value       = {
    name = aws_kms_alias.key_alias.name
    arn  = aws_kms_key.key.arn
  }
  description = "The alias of KMS key."
}

output "artifact_bucket" {
  value       = {
    arn  = aws_s3_bucket.cicd.arn
    name = aws_s3_bucket.cicd.id
  description = "The ARN and name of S3 bucket used for storing logs and artifacts of CICD."
  }
}

output "ecr" {
  value       = {
    web = aws_ecr_repository.ecr_web.name
    api = aws_ecr_repository.ecr_api.name
  }
  description = "The name of the ECR."
}

output "microscanner_token_name" {
  value       = aws_ssm_parameter.microscanner_token.name
  description = "The name of the Microscanner Token SSM Parameter."
  sensitive   = true
}
