resource "aws_codepipeline" "cpipeline_api_eks" {
  name     = "${var.naming}-pipeline-api-eks"
  role_arn = aws_iam_role.cpipeline_role.arn

  artifact_store {
    location = var.artifact_bucket.name
    type     = "S3"
  }

  stage {
    name = "Source"

    action {
      name             = "Source"
      category         = "Source"
      owner            = "AWS"
      provider         = "ECR"
      version          = "1"
      output_artifacts = ["api_eks_pipeline"]

      configuration = {
        RepositoryName = var.ecr.api
        ImageTag       = "latest"
      }
    }
  }

  stage {
    name = "Invoke"

    action {
      name             = "Invoke"
      category         = "Invoke"
      owner            = "AWS"
      provider         = "Lambda"
      input_artifacts  = ["api_eks_pipeline"]
      version          = "1"

      configuration = {
        FunctionName = var.lambda_deploy_name
      }
    }
  }
}