variable "region" {
    type        = string
    description = "AWS region where solution should be deployed."
}

variable "short_region" {
    type = string
    description = "Short version of above defined AWS region. Eg. eu-west-1 >> ew1 ."
}

variable "environment" {
    type = string
    description = "Environment type. Eg. Development, UAT, Production."
}

variable "project" {
    type = string
    description = "Project name or abreviations."
}

variable "microscanner_token" {
    type = string
    description = "Microscanner Token."
}

variable "github_repos" {
    type = map
    description = "GitHub Repository URL."
}

variable "github_token" {
    type = string
    description = "GitHub Repository Token."
}
