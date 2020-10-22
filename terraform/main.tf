locals {
    naming = "${lower(var.short_region)}-${lower(var.environment)}-${lower(var.project)}"
    common_tags = {
        "Region" = var.region
        "Environment" = var.environment
        "Project" = var.project
    }
}

module "common" {
  source = "./modules/common"

  naming      = local.naming
  common_tags = local.common_tags

  microscanner_token = var.microscanner_token
}

module "cbuild" {
  source = "./modules/cbuild"

  naming      = local.naming
  region      = var.region
  common_tags = local.common_tags

  encryption_key          = module.common.encryption_key
  artifact_bucket         = module.common.artifact_bucket
  ecr                     = module.common.ecr
  github_repos            = var.github_repos
  github_token            = var.github_token
  microscanner_token_name = module.common.microscanner_token_name
}

module "lambda" {
  source = "./modules/lambda"

  naming      = local.naming
  region      = var.region
  common_tags = local.common_tags

  artifact_bucket  = module.common.artifact_bucket
}

module "cpipeline" {
  source = "./modules/cpipeline"

  naming      = local.naming
  region      = var.region
  common_tags = local.common_tags

  artifact_bucket       = module.common.artifact_bucket
  ecr                   = module.common.ecr
  lambda_deploy_name =  module.lambda.lambda_deploy_name
}
