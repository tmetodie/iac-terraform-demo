variable "naming" {
    type = string
    description = "Naming convention."
}

variable "region" {
    type        = string
    description = "AWS region where solution should be deployed."
}

variable "common_tags" {
    type = map
    description = "Common deployment tags."
}

variable "encryption_key" {
    type = map
    description = "The alias of KMS key."
}

variable "artifact_bucket" {
    type = map
    description = "The ARN of S3 bucket used for storing logs and artifacts of CICD."
}

variable "ecr" {
    type = map
    description = "The name of the ECR."
}

variable "microscanner_token_name" {
    type = string
    description = "The name of the Microscanner Token SSM Parameter."
}

variable "github_repos" {
    type = map
    description = "GitHub Repository URL."
}

variable "github_token" {
    type = string
    description = "GitHub Repository Token."
}
