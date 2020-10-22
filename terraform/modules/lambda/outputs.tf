output "lambda_deploy_name" {
  value       = "${var.naming}-cicd-deploy-eks"
  description = "The name of the Lambda for EKS deployment."
  sensitive   = true
}