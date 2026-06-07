output "region" {
  value       = var.aws_region
  description = "Target deployment region"
}

output "vpc_id" {
  value       = aws_vpc.bedrock_vpc.id
  description = "The unique instance identifier of the cluster VPC"
}

output "cluster_name" {
  value       = aws_eks_cluster.eks.name
  description = "The system name mapping the cluster"
}

output "cluster_endpoint" {
  value       = aws_eks_cluster.eks.endpoint
  description = "The loopback secure socket layer path for kubectl orchestration"
}

output "assets_bucket_name" {
  value       = "bedrock-assets-alt-soe-025-4831"
  description = "The foundational assets target namespace prefix"
}
