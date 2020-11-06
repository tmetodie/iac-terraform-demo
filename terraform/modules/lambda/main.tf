resource "aws_lambda_function" "deploy_eks" {
  filename      = "./${path.module}/python_scripts/eks_deploy_lambda.zip"
  source_code_hash = filebase64sha256("./${path.module}/python_scripts/eks_deploy_lambda.zip")
  function_name = "${var.naming}-cicd-deploy-eks"
  role          = aws_iam_role.eks_deploy.arn
  handler       = "main.handler"

  runtime = "python3.6"

  environment {
    variables = {
      CLUSTER_NAME = "${var.naming}-eks"
    }
  }
}
