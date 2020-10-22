resource "null_resource" "build_lambda_package" {
  triggers = {
    build_number = timestamp()
  }

  provisioner "local-exec" {
    command = "./package.sh eks_deploy_lambda"
    working_dir = "../python_scripts"
    interpreter = ["/bin/bash", "-c"]
  }
}

resource "aws_lambda_function" "deploy_eks" {
  depends_on    = [null_resource.build_lambda_package]
  filename      = "../python_scripts/eks_deploy_lambda.zip"
  function_name = "${var.naming}-cicd-deploy-eks"
  role          = aws_iam_role.eks_deploy.arn
  handler       = "main.handler"

  runtime = "python3.6"

  environment {
    variables = {
      CLUSTER_NAME = "${var.naming}-eks"
    }
  }

  provisioner "local-exec" {
    command = "./clean.sh eks_deploy_lambda"
    working_dir = "../python_scripts"
    interpreter = ["/bin/bash", "-c"]
  }
}
