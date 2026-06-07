resource "aws_db_subnet_group" "rds_subnet_group" {
  name        = "project-bedrock-rds-subnet-group"
  subnet_ids  = aws_subnet.private[*].id
  description = "Isolated private subnet assignment map for capstone database instances"
  tags = {
    Project = "karatu-2025-capstone"
    Name    = "project-bedrock-rds-subnet-group"
  }
}

resource "aws_security_group" "rds_sg" {
  name        = "project-bedrock-rds-sg"
  description = "Strict Zero-Trust database firewall shielding storage engines"
  vpc_id      = aws_vpc.bedrock_vpc.id

  ingress {
    description = "Permit MySQL query traffic exclusively from EKS node group capacity"
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    security_groups = [
      aws_eks_cluster.bedrock.vpc_config[0].cluster_security_group_id
    ]
  }

  ingress {
    description = "Permit PostgreSQL query traffic exclusively from EKS node group capacity"
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    security_groups = [
      aws_eks_cluster.bedrock.vpc_config[0].cluster_security_group_id
    ]
  }

  egress {
    description = "Allow private outbound responses safely back to internal interfaces"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Project = "karatu-2025-capstone"
    Name    = "project-bedrock-rds-sg"
  }
}

resource "aws_db_instance" "mysql_db" {
  identifier             = "project-bedrock-mysql"
  engine                 = "mysql"
  engine_version         = "8.0"
  instance_class         = "db.t3.micro"
  allocated_storage      = 20
  max_allocated_storage  = 50
  storage_type           = "gp3"
  db_name                = "bedrockdb"
  username               = "bedrock_admin"
  password               = "BedrockSecure2025!"
  db_subnet_group_name   = aws_db_subnet_group.rds_subnet_group.name
  vpc_security_group_ids = [aws_security_group.rds_sg.id]
  skip_final_snapshot    = true
  publicly_accessible    = false
  tags = {
    Project = "karatu-2025-capstone"
    Name    = "project-bedrock-mysql"
  }
}

resource "aws_db_instance" "postgres_db" {
  identifier             = "project-bedrock-postgres"
  engine                 = "postgres"
  engine_version         = "15"
  instance_class         = "db.t3.micro"
  allocated_storage      = 20
  max_allocated_storage  = 50
  storage_type           = "gp3"
  db_name                = "bedrockdb"
  username               = "bedrock_admin"
  password               = "BedrockSecure2025!"
  db_subnet_group_name   = aws_db_subnet_group.rds_subnet_group.name
  vpc_security_group_ids = [aws_security_group.rds_sg.id]
  skip_final_snapshot    = true
  publicly_accessible    = false
  tags = {
    Project = "karatu-2025-capstone"
    Name    = "project-bedrock-postgres"
  }
}

resource "aws_dynamodb_table" "carts_table" {
  name         = "project-bedrock-carts"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "id"
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
  }
  tags = {
    Project = "karatu-2025-capstone"
    Name    = "project-bedrock-carts"
  }
}
