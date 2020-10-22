
resource "aws_s3_bucket" "cicd" {
  bucket = "${var.naming}-cicd-s3"
  acl    = "private"

  versioning {
    enabled = true
  }

  lifecycle_rule {
    id      = "build_log"
    enabled = true
    prefix  = "build_log*"

    tags = var.common_tags

    transition {
      days          = 30
      storage_class = "STANDARD_IA"
    }

    transition {
      days          = 60
      storage_class = "GLACIER"
    }

    expiration {
      days = 200
    }
  }

  tags = var.common_tags
}

####### KMS #######
resource "aws_kms_key" "key" {
  key_usage               = "ENCRYPT_DECRYPT"
  deletion_window_in_days = 10
  is_enabled              = true
  enable_key_rotation     = true

  tags = merge({Name = "${var.naming}-cicd-kms"}, var.common_tags)
}

resource "aws_kms_alias" "key_alias" {
  name          = "alias/${var.naming}-cicd"
  target_key_id = aws_kms_key.key.id
}


####### ECR #######
resource "aws_ecr_repository" "ecr_web" {
  name = "${var.naming}-cicd-ecr-web"
  image_tag_mutability = "MUTABLE"
  image_scanning_configuration {
    scan_on_push = true
  }

  encryption_configuration {
    encryption_type = "AES256"
  }
}

resource "aws_ecr_repository" "ecr_api" {
  name = "${var.naming}-cicd-ecr-api"
  image_tag_mutability = "MUTABLE"
  image_scanning_configuration {
    scan_on_push = true
  }

  encryption_configuration {
    encryption_type = "AES256"
  }
}

resource "aws_ecr_lifecycle_policy" "ecr_policy_web" {
  repository = aws_ecr_repository.ecr_web.name

  policy = <<EOF
{
    "rules": [
        {
            "rulePriority": 1,
            "description": "Expire images older than 2 months",
            "selection": {
                "tagStatus": "untagged",
                "countType": "sinceImagePushed",
                "countUnit": "days",
                "countNumber": 60
            },
            "action": {
                "type": "expire"
            }
        }
    ]
}
EOF
}

resource "aws_ecr_lifecycle_policy" "ecr_policy_api" {
  repository = aws_ecr_repository.ecr_api.name

  policy = <<EOF
{
    "rules": [
        {
            "rulePriority": 1,
            "description": "Expire images older than 2 months",
            "selection": {
                "tagStatus": "untagged",
                "countType": "sinceImagePushed",
                "countUnit": "days",
                "countNumber": 60
            },
            "action": {
                "type": "expire"
            }
        }
    ]
}
EOF
}

####### SSM #######
resource "aws_ssm_parameter" "microscanner_token" {
  name        = "/${var.naming}/microscanner_token"
  description = "Microscanner Token"
  type        = "SecureString"
  value       = var.microscanner_token
  key_id      = aws_kms_key.key.key_id

  tags = var.common_tags
}