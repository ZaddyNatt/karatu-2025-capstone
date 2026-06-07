terraform {
  required_version = ">= 1.5.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.0"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "~> 2.0"
    }
  }

  backend "s3" {
    bucket  = "bedrock-assets-alt-soe-025-4831-state"
    key     = "phase2/terraform.tfstate"
    region  = "us-east-1"
    encrypt = true
  }
}

provider "aws" {
  region = var.aws_region
}

data "aws_eks_cluster_auth" "cluster" {
  name = aws_eks_cluster.bedrock.name
}

provider "kubernetes" {
  host                   = aws_eks_cluster.bedrock.endpoint
  cluster_ca_certificate = base64decode(aws_eks_cluster.bedrock.certificate_authority[0].data)
  token                  = data.aws_eks_cluster_auth.cluster.token
}

provider "helm" {
  kubernetes {
    host                   = aws_eks_cluster.bedrock.endpoint
    cluster_ca_certificate = base64decode(aws_eks_cluster.bedrock.certificate_authority[0].data)
    token                  = data.aws_eks_cluster_auth.cluster.token
  }
}
resource "kubernetes_namespace" "retail_app" {
  metadata {
    name = "retail-app"
    labels = {
      Project = var.project_name
    }
  }
}

resource "kubernetes_cluster_role_binding" "bedrock_developer_view_binding" {
  metadata {
    name = "bedrock-developer-view-binding"
  }

  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = "view"
  }

  subject {
    kind      = "User"
    name      = "bedrock-dev-view"
    api_group = "rbac.authorization.k8s.io"
  }
}

resource "helm_release" "aws_load_balancer_controller" {
  name       = "aws-load-balancer-controller"
  repository = "https://aws.github.io/eks-charts"
  chart      = "aws-load-balancer-controller"
  namespace  = "kube-system"

  set {
    name  = "clusterName"
    value = "project-bedrock-cluster"
  }

  set {
    name  = "region"
    value = var.aws_region
  }

  set {
    name  = "vpcId"
    value = aws_eks_cluster.bedrock.vpc_config[0].vpc_id
  }
}
