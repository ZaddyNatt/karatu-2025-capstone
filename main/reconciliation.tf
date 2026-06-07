# State Migration and Resource Adoption Alignment

# 1. Renamed Infrastructure Resource State Mapping (moved blocks)
moved {
  from = aws_subnet.public_a
  to   = aws_subnet.public[0]
}

moved {
  from = aws_subnet.public_b
  to   = aws_subnet.public[1]
}

moved {
  from = aws_subnet.private_a
  to   = aws_subnet.private[0]
}

moved {
  from = aws_subnet.private_b
  to   = aws_subnet.private[1]
}

moved {
  from = aws_eks_cluster.eks
  to   = aws_eks_cluster.bedrock
}

moved {
  from = aws_eks_node_group.nodes
  to   = aws_eks_node_group.bedrock_nodes
}

moved {
  from = aws_dynamodb_table.carts
  to   = aws_dynamodb_table.carts_table
}

moved {
  from = aws_db_instance.mysql
  to   = aws_db_instance.mysql_db
}

moved {
  from = aws_db_instance.postgres
  to   = aws_db_instance.postgres_db
}

moved {
  from = aws_security_group.db_sg
  to   = aws_security_group.rds_sg
}

moved {
  from = aws_db_subnet_group.db_subnet_group
  to   = aws_db_subnet_group.rds_subnet_group
}

moved {
  from = aws_iam_role.cluster_role
  to   = aws_iam_role.cluster
}

moved {
  from = aws_iam_role.node_role
  to   = aws_iam_role.node_group
}

moved {
  from = aws_iam_role_policy_attachment.eks_cluster_policy
  to   = aws_iam_role_policy_attachment.cluster_AmazonEKSClusterPolicy
}

moved {
  from = aws_iam_role_policy_attachment.node_worker_policy
  to   = aws_iam_role_policy_attachment.node_AmazonEKSWorkerNodePolicy
}

moved {
  from = aws_iam_role_policy_attachment.node_cni_policy
  to   = aws_iam_role_policy_attachment.node_AmazonEKS_CNI_Policy
}

moved {
  from = aws_iam_role_policy_attachment.node_registry_policy
  to   = aws_iam_role_policy_attachment.node_AmazonEC2ContainerRegistryReadOnly
}

moved {
  from = aws_route_table.public_rt
  to   = aws_route_table.public
}

moved {
  from = aws_route_table.private_rt
  to   = aws_route_table.private
}

moved {
  from = aws_route_table_association.public_a_assoc
  to   = aws_route_table_association.public[0]
}

moved {
  from = aws_route_table_association.public_b_assoc
  to   = aws_route_table_association.public[1]
}

moved {
  from = aws_route_table_association.private_a_assoc
  to   = aws_route_table_association.private[0]
}

moved {
  from = aws_route_table_association.private_b_assoc
  to   = aws_route_table_association.private[1]
}

moved {
  from = aws_eip.nat_eip
  to   = aws_eip.nat
}

moved {
  from = kubernetes_cluster_role_binding.bedrock_dev_view
  to   = kubernetes_cluster_role_binding.bedrock_developer_view_binding
}

# 2. Existing Cloud Resources Import Mapping (import blocks)
import {
  to = aws_cloudwatch_log_group.eks_cluster_logs
  id = "/aws/eks/project-bedrock-cluster/cluster"
}
