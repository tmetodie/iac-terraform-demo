variable "naming" {
    type = string
    description = "Naming convention."
}

variable "common_tags" {
    type = map
    description = "Common deployment tags."
}

variable "microscanner_token" {
    type = string
    description = "Microscanner Token."
}