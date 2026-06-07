output "region" {
  value       = var.aws_region
  description = "The target AWS deployment region."
}

output "assets_bucket_name" {
  value       = "bedrock-assets-alt-soe-025-4831"
  description = "The allocated unique asset storage bucket identifier."
}

output "mysql_endpoint" {
  value       = aws_db_instance.mysql_db.endpoint
  description = "Programmatic connection url string routing to the transactional MySQL database"
}

output "postgres_endpoint" {
  value       = aws_db_instance.postgres_db.endpoint
  description = "Programmatic connection url string routing to the relational PostgreSQL catalog database"
}

output "dynamodb_table_name" {
  value       = aws_dynamodb_table.carts_table.name
  description = "The target data reference handle mapped to the serverless tracking engine"
}

output "cluster_endpoint" {
  value       = aws_eks_cluster.bedrock.endpoint
  description = "The EKS control plane API server URL endpoint"
}

output "cluster_name" {
  value       = aws_eks_cluster.bedrock.name
  description = "The physical EKS cluster identifier"
}

output "vpc_id" {
  value       = aws_vpc.bedrock_vpc.id
  description = "The physical VPC identifier"
}
