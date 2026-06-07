variable "aws_region" {
  type    = string
  default = "us-east-1"
}

variable "project_name" {
  type    = string
  default = "karatu-2025-capstone"
}

variable "vpc_name" {
  type    = string
  default = "project-bedrock-vpc"
}

variable "cluster_name" {
  type    = string
  default = "project-bedrock-cluster"
}

variable "node_desired_size" {
  type    = number
  default = 2
}

variable "node_min_size" {
  type    = number
  default = 1
}
