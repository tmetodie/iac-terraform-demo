data "aws_caller_identity" "current" {}

resource "aws_codebuild_source_credential" "github_cred" {
  auth_type   = "PERSONAL_ACCESS_TOKEN"
  server_type = "GITHUB"
  token       = var.github_token
}

resource "aws_codebuild_project" "web" {
  depends_on   = [aws_codebuild_source_credential.github_cred]
  name         = "${var.naming}-cicd-cbuild-web"
  service_role = aws_iam_role.cb_role.arn
  source_version = "master"

  artifacts {
    type = "NO_ARTIFACTS"
  }

  environment {
    type = "LINUX_CONTAINER"
    compute_type = "BUILD_GENERAL1_SMALL"
    image = "aws/codebuild/standard:4.0"
    privileged_mode = true
        
    environment_variable {
      name  = "AWS_ACCOUNT_ID"
      value = data.aws_caller_identity.current.account_id
    } 

    environment_variable {
      name  = "AWS_DEFAULT_REGION"
      value = var.region
    }
    
    environment_variable {
      name  = "IMAGE_REPO_NAME"
      value = var.ecr.web
    }
    
    environment_variable {
      name  = "MICROSCANNER_TOKEN"
      value = var.microscanner_token_name
      type  = "PARAMETER_STORE"
    }
  }

  source {
    type = "GITHUB"
    location = var.github_repos.web
    git_clone_depth = 1
    git_submodules_config {
      fetch_submodules = true
    }
  }

  logs_config {
    s3_logs {
      status   = "ENABLED"
      location = "${var.artifact_bucket.arn}/build_log_web"
    }
  }

  cache {
    type = "NO_CACHE"
  }

  encryption_key = var.encryption_key.name
  build_timeout = 10
  badge_enabled = false
  tags = merge({ "Name" = "${var.naming}-cicd-cbuild" }, var.common_tags)
}

resource "aws_codebuild_webhook" "web" {
  depends_on   = [aws_codebuild_project.web]
  project_name = aws_codebuild_project.web.name

  filter_group {
    filter {
      type    = "EVENT"
      pattern = "PUSH"
    }

    filter {
      type    = "HEAD_REF"
      pattern = "master"
    }
  }
  
  provisioner "local-exec" {
    command = "aws codebuild start-build --project-name ${aws_codebuild_project.web.name} --region ${var.region}"
    interpreter = ["/bin/bash", "-c"]
  }
}

resource "aws_codebuild_project" "api" {
  depends_on   = [aws_codebuild_source_credential.github_cred]
  name         = "${var.naming}-cicd-cbuild-api"
  service_role = aws_iam_role.cb_role.arn
  source_version = "master"

  artifacts {
    type = "NO_ARTIFACTS"
  }

  environment {
    type = "LINUX_CONTAINER"
    compute_type = "BUILD_GENERAL1_SMALL"
    image = "aws/codebuild/standard:4.0"
    privileged_mode = true
        
    environment_variable {
      name  = "AWS_ACCOUNT_ID"
      value = data.aws_caller_identity.current.account_id
    } 

    environment_variable {
      name  = "AWS_DEFAULT_REGION"
      value = var.region
    }
    
    environment_variable {
      name  = "IMAGE_REPO_NAME"
      value = var.ecr.api
    }
    
    environment_variable {
      name  = "MICROSCANNER_TOKEN"
      value = var.microscanner_token_name
      type  = "PARAMETER_STORE"
    }
  }

  source {
    type = "GITHUB"
    location = var.github_repos.api
    git_clone_depth = 1
    git_submodules_config {
      fetch_submodules = true
    }
  }

  logs_config {
    s3_logs {
      status   = "ENABLED"
      location = "${var.artifact_bucket.arn}/build_log_api"
    }
  }

  cache {
    type = "NO_CACHE"
  }

  encryption_key = var.encryption_key.name
  build_timeout = 10
  badge_enabled = false
  tags = merge({ "Name" = "${var.naming}-cicd-cbuild" }, var.common_tags)
}

resource "aws_codebuild_webhook" "webhook_api" {
  depends_on   = [aws_codebuild_project.api]
  project_name = aws_codebuild_project.api.name

  filter_group {
    filter {
      type    = "EVENT"
      pattern = "PUSH"
    }

    filter {
      type    = "HEAD_REF"
      pattern = "master"
    }
  }
  
  provisioner "local-exec" {
    command = "aws codebuild start-build --project-name ${aws_codebuild_project.api.name} --region ${var.region}"
    interpreter = ["/bin/bash", "-c"]
  }
}
