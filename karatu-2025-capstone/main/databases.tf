resource "aws_security_group" "db_sg" {
  name        = "project-bedrock-db-sg"
  description = "Security group for database instances"
  vpc_id      = aws_vpc.bedrock_vpc.id

  ingress {
    description     = "Inbound traffic from EKS worker nodes to MySQL"
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    security_groups = [aws_eks_cluster.eks.vpc_config[0].cluster_security_group_id]
  }

  ingress {
    description     = "Inbound traffic from EKS worker nodes to PostgreSQL"
    from_port       = 5432
    to_port         = 5432
    protocol        = "tcp"
    security_groups = [aws_eks_cluster.eks.vpc_config[0].cluster_security_group_id]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = local.global_tags
}

resource "aws_db_subnet_group" "db_subnet_group" {
  name       = "project-bedrock-db-subnet-group"
  subnet_ids = [aws_subnet.private_a.id, aws_subnet.private_b.id]

  tags = local.global_tags
}

resource "aws_db_instance" "mysql" {
  identifier             = "project-bedrock-mysql"
  allocated_storage      = 20
  engine                 = "mysql"
  engine_version         = "8.0.42"
  instance_class         = "db.t4g.micro"
  db_name                = "bedrockdb"
  username               = "admin"
  password               = "SecurePassword123!"
  db_subnet_group_name   = aws_db_subnet_group.db_subnet_group.name
  vpc_security_group_ids = [aws_security_group.db_sg.id]
  skip_final_snapshot    = true

  tags = local.global_tags
}

resource "aws_db_instance" "postgres" {
  identifier             = "project-bedrock-postgres"
  allocated_storage      = 20
  engine                 = "postgres"
  engine_version         = "16.3"
  instance_class         = "db.t4g.micro"
  db_name                = "bedrockdb"
  username               = "postgres"
  password               = "SecurePassword123!"
  db_subnet_group_name   = aws_db_subnet_group.db_subnet_group.name
  vpc_security_group_ids = [aws_security_group.db_sg.id]
  skip_final_snapshot    = true

  tags = local.global_tags
}

resource "aws_dynamodb_table" "carts" {
  name           = "project-bedrock-carts"
  billing_mode   = "PROVISIONED"
  read_capacity  = 5
  write_capacity = 5
  hash_key       = "id"

  attribute {
    name = "id"
    type = "S"
  }

  attribute {
    name = "customerId"
    type = "S"
  }

  global_secondary_index {
    name               = "idx_global_customerId"
    hash_key           = "customerId"
    projection_type    = "ALL"
    read_capacity      = 5
    write_capacity     = 5
  }

  tags = local.global_tags
}
