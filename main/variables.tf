variable "aws_region" {
  type        = string
  default     = "us-east-1"
}
variable "project_tag" {
  type        = string
  default     = "karatu-2025-capstone"
}
variable "project_name" {
  type        = string
  default     = "karatu-2025-capstone"
  description = "Mandatory operational tracking tag for grading compliance."
}
variable "cluster_name" {
  type        = string
  default     = "project-bedrock-cluster"
}
variable "vpc_cidr" {
  type        = string
  default     = "10.0.0.0/16"
}
variable "public_subnet_cidrs" {
  type        = list(string)
  default     = ["10.0.1.0/24", "10.0.2.0/24"]
}
variable "private_subnet_cidrs" {
  type        = list(string)
  default     = ["10.0.11.0/24", "10.0.12.0/24"]
}
