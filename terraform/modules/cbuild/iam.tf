data "aws_iam_policy_document" "cb_policy_doc" {
  statement {
    effect = "Allow"
    resources = [
      var.artifact_bucket.arn,
      "${var.artifact_bucket.arn}/*"
    ]
    actions = ["s3:*"]
  }
  
  statement {
    effect = "Allow"
    resources = [
      "arn:aws:logs:${var.region}:${data.aws_caller_identity.current.account_id}:log-group:/aws/codebuild/${var.naming}-web",
      "arn:aws:logs:${var.region}:${data.aws_caller_identity.current.account_id}:log-group:/aws/codebuild/${var.naming}-cicd-cbuild-web:*",
      "arn:aws:logs:${var.region}:${data.aws_caller_identity.current.account_id}:log-group:/aws/codebuild/${var.naming}-cicd-cbuild-api",
      "arn:aws:logs:${var.region}:${data.aws_caller_identity.current.account_id}:log-group:/aws/codebuild/${var.naming}-cicd-cbuild-api:*"
    ]
    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents"
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

  statement {
    effect = "Allow"
    resources = ["arn:aws:codebuild:${var.region}:${data.aws_caller_identity.current.account_id}:report-group/${var.naming}-cicd-cbuild-*"]
    actions = [
      "codebuild:CreateReportGroup",
      "codebuild:CreateReport",
      "codebuild:UpdateReport",
      "codebuild:BatchPutTestCases",
      "codebuild:BatchPutCodeCoverages"
    ]
  }

  statement {
    effect = "Allow"
    resources = ["arn:aws:ssm:${var.region}:${data.aws_caller_identity.current.account_id}:parameter/${var.naming}/*"]
    actions = [
      "ssm:PutParameter",
      "ssm:GetParameter",
      "ssm:GetParameters"
    ]
  }

  statement {
    effect = "Allow"
    resources = [var.encryption_key.arn]
    actions = [
      "kms:Decrypt",
      "kms:Encrypt",
      "kms:GenerateDataKey"  
    ]
  }
}

resource "aws_iam_policy" "cb_policy" {
  name        = "${var.naming}-cbuild-policy"
  policy      = data.aws_iam_policy_document.cb_policy_doc.json
  path        = "/${var.naming}/cicd/"
}

resource "aws_iam_role" "cb_role" {
  name               = "${var.naming}-cbuild-role"
  path               = "/${var.naming}/cicd/"
  tags               = merge({ "Name" = "${var.naming}-cbuild-role" }, var.common_tags)
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "codebuild.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "cbuild" {
  role       = aws_iam_role.cb_role.name
  policy_arn = aws_iam_policy.cb_policy.arn
}

resource "aws_iam_role_policy_attachment" "ecr" {
  role       = aws_iam_role.cb_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryPowerUser"
}
