data "aws_caller_identity" "current" {}

data "aws_iam_policy_document" "eks_deploy" {
  statement {
    effect = "Allow"
    resources = [
      var.artifact_bucket.arn,
      "${var.artifact_bucket.arn}/*"
    ]
    actions = [
        "s3:ListBucket",
        "s3:GetObject"
    ]
  }
  
  statement {
    effect = "Allow"
    resources = [
      "arn:aws:eks:${var.region}:${data.aws_caller_identity.current.account_id}:cluster/${var.naming}-eks"
    ]
    actions = [
      "eks:DescribeCluster"
    ]
  }
}

resource "aws_iam_policy" "eks_deploy" {
  name        = "${var.naming}-lambda-eks-deploy-policy"
  policy      = data.aws_iam_policy_document.eks_deploy.json
  path        = "/${var.naming}/cicd/"
}

resource "aws_iam_role" "eks_deploy" {
  name = "${var.naming}-lambda-eks-deploy-role"
  path               = "/${var.naming}/cicd/"
  tags               = merge({ "Name" = "${var.naming}-lambda-eks-deploy-policy" }, var.common_tags)

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "eks_deploy" {
  role       = aws_iam_role.eks_deploy.name
  policy_arn = aws_iam_policy.eks_deploy.arn
}