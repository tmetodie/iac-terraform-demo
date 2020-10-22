data "aws_caller_identity" "current" {}

resource "aws_iam_role" "cpipeline_role" {
  name = "${var.naming}-cpipeline-role"
  path = "/${var.naming}/cicd/"
  tags = merge({ "Name" = "${var.naming}-cpipeline-role" }, var.common_tags)

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "codepipeline.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

data "aws_iam_policy_document" "cpipeline_policy_doc" {
  statement {
    effect = "Allow"
    resources = [
      var.artifact_bucket.arn,
      "${var.artifact_bucket.arn}/*"
    ]
    actions = [
      "s3:GetObject",
      "s3:GetObjectVersion",
      "s3:GetBucketVersioning",
      "s3:PutObject"
    ]
  }

  statement {
    effect = "Allow"
    resources = [
      "arn:aws:lambda:${var.region}:${data.aws_caller_identity.current.account_id}:function:${var.lambda_deploy_name}"
    ]
    actions = [
      "lambda:InvokeFunction"
    ]
  }

  statement {
    effect = "Allow"
    resources = ["arn:aws:s3:::codepipeline-${var.region}-*"]
    actions = [
      "s3:PutObject",
      "s3:GetObject",
      "s3:GetObjectVersion",
      "s3:GetBucketAcl",
      "s3:GetBucketLocation"
    ]
  }
}

resource "aws_iam_policy" "cpipeline_policy" {
  name        = "${var.naming}-cpipeline-policy"
  policy      = data.aws_iam_policy_document.cpipeline_policy_doc.json
  path        = "/${var.naming}/cicd/"
}

resource "aws_iam_role_policy_attachment" "cbuild" {
  role       = aws_iam_role.cpipeline_role.name
  policy_arn = aws_iam_policy.cpipeline_policy.arn
}

resource "aws_iam_role_policy_attachment" "ecr" {
  role       = aws_iam_role.cpipeline_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryPowerUser"
}
