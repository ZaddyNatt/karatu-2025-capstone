data "aws_availability_zones" "available" {
  state = "available"
}

locals {
  az_a = data.aws_availability_zones.available.names[0]
  az_b = data.aws_availability_zones.available.names[1]
  
  global_tags = {
    Project = var.project_name
  }
}

# ==========================================
# NETWORKING LAYER (CUSTOM ENTERPRISE VPC)
# ==========================================

resource "aws_vpc" "bedrock_vpc" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = merge(local.global_tags, {
    Name = var.vpc_name
  })
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.bedrock_vpc.id

  tags = merge(local.global_tags, {
    Name = "project-bedrock-igw"
  })
}

# Public Subnets (Ingress / ALB Lane)
resource "aws_subnet" "public_a" {
  vpc_id            = aws_vpc.bedrock_vpc.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = local.az_a
  map_public_ip_on_launch = true

  tags = merge(local.global_tags, {
    Name                     = "project-bedrock-public-us-east-1a"
    "kubernetes.io/role/elb" = "1"
  })
}

resource "aws_subnet" "public_b" {
  vpc_id            = aws_vpc.bedrock_vpc.id
  cidr_block        = "10.0.2.0/24"
  availability_zone = local.az_b
  map_public_ip_on_launch = true

  tags = merge(local.global_tags, {
    Name                     = "project-bedrock-public-us-east-1b"
    "kubernetes.io/role/elb" = "1"
  })
}

# Private Subnets (Compute Node / EKS Lane)
resource "aws_subnet" "private_a" {
  vpc_id            = aws_vpc.bedrock_vpc.id
  cidr_block        = "10.0.11.0/24"
  availability_zone = local.az_a

  tags = merge(local.global_tags, {
    Name                              = "project-bedrock-private-us-east-1a"
    "kubernetes.io/role/internal-elb" = "1"
  })
}

resource "aws_subnet" "private_b" {
  vpc_id            = aws_vpc.bedrock_vpc.id
  cidr_block        = "10.0.12.0/24"
  availability_zone = local.az_b

  tags = merge(local.global_tags, {
    Name                              = "project-bedrock-private-us-east-1b"
    "kubernetes.io/role/internal-elb" = "1"
  })
}

# Budget Optimized Outbound Gateways
resource "aws_eip" "nat_eip" {
  domain = "vpc"
  tags   = local.global_tags
}

resource "aws_nat_gateway" "nat" {
  allocation_id = aws_eip.nat_eip.id
  subnet_id     = aws_subnet.public_a.id

  tags = merge(local.global_tags, {
    Name = "project-bedrock-nat"
  })
}

# Routing Tables
resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.bedrock_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = merge(local.global_tags, {
    Name = "project-bedrock-public-rt"
  })
}

resource "aws_route_table" "private_rt" {
  vpc_id = aws_vpc.bedrock_vpc.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat.id
  }

  tags = merge(local.global_tags, {
    Name = "project-bedrock-private-rt"
  })
}

# Route Table Associations
resource "aws_route_table_association" "public_a_assoc" {
  subnet_id      = aws_subnet.public_a.id
  route_table_id = aws_route_table.public_rt.id
}

resource "aws_route_table_association" "public_b_assoc" {
  subnet_id      = aws_subnet.public_b.id
  route_table_id = aws_route_table.public_rt.id
}

resource "aws_route_table_association" "private_a_assoc" {
  subnet_id      = aws_subnet.private_a.id
  route_table_id = aws_route_table.private_rt.id
}

resource "aws_route_table_association" "private_b_assoc" {
  subnet_id      = aws_subnet.private_b.id
  route_table_id = aws_route_table.private_rt.id
}

# ==========================================
# IAM ACCESS SECURITY LAYER
# ==========================================

# Control Plane Execution Role
resource "aws_iam_role" "cluster_role" {
  name = "project-bedrock-cluster-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "eks.amazonaws.com"
      }
    }]
  })
  
  tags = local.global_tags
}

resource "aws_iam_role_policy_attachment" "eks_cluster_policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.cluster_role.name
}

# Worker Node Group Execution Role
resource "aws_iam_role" "node_role" {
  name = "project-bedrock-node-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "ec2.amazonaws.com"
      }
    }]
  })

  tags = local.global_tags
}

resource "aws_iam_role_policy_attachment" "node_worker_policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = aws_iam_role.node_role.name
}

resource "aws_iam_role_policy_attachment" "node_cni_policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = aws_iam_role.node_role.name
}

resource "aws_iam_role_policy_attachment" "node_registry_policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = aws_iam_role.node_role.name
}

# ==========================================
# COMPUTE LAYER (AMAZON EKS CLUSTER CORES)
# ==========================================

resource "aws_eks_cluster" "eks" {
  name     = var.cluster_name
  role_arn = aws_iam_role.cluster_role.arn
  version  = "1.31"

  vpc_config {
    subnet_ids              = [aws_subnet.private_a.id, aws_subnet.private_b.id]
    endpoint_private_access = true
    endpoint_public_access  = true
  }

  depends_on = [
    aws_iam_role_policy_attachment.eks_cluster_policy
  ]

  tags = local.global_tags
}

resource "aws_eks_node_group" "nodes" {
  cluster_name    = aws_eks_cluster.eks.name
  node_group_name = "project-bedrock-node-group"
  node_role_arn   = aws_iam_role.node_role.arn
  subnet_ids      = [aws_subnet.private_a.id, aws_subnet.private_b.id]

  instance_types = ["t3.small"]

  scaling_config {
    desired_size = var.node_desired_size
    max_size     = 3
    min_size     = var.node_min_size
  }

  update_config {
    max_unavailable = 1
  }

  depends_on = [
    aws_iam_role_policy_attachment.node_worker_policy,
    aws_iam_role_policy_attachment.node_cni_policy,
    aws_iam_role_policy_attachment.node_registry_policy
  ]

  tags = local.global_tags
}
