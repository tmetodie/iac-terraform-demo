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

variable "artifact_bucket" {
    type = map
    description = "The ARN of S3 bucket used for storing logs and artifacts of CICD."
}
