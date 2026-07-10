resource "aws_security_group" "rds" {
  name        = "${var.project_name}-rds-sg"
  description = "Security Group for RDS"
  vpc_id      = var.vpc_id

  ingress {
    description = "PostgreSQL"
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"

    # We'll replace this with the ECS Security Group in Lesson 4
    cidr_blocks = ["10.0.0.0/16"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.project_name}-rds-sg"
  }
}

resource "aws_db_subnet_group" "rds" {
  name       = "${var.project_name}-db-subnet-group"
  subnet_ids = var.private_subnet_ids

  tags = {
    Name = "${var.project_name}-db-subnet-group"
  }
}

resource "aws_db_parameter_group" "postgres" {
  name   = "${var.project_name}-postgres-params"
  family = "postgres15"

  parameter {
    name  = "log_statement"
    value = "all"
  }

  tags = {
    Name = "${var.project_name}-postgres-params"
  }
}

resource "aws_db_instance" "this" {
  identifier             = "${var.project_name}-postgres"
  allocated_storage      = 20
  engine                 = "postgres"
  engine_version         = "15"
  instance_class         = var.instance_class

  db_name                = var.db_name
  username               = var.db_username
  password               = var.db_password

  db_subnet_group_name   = aws_db_subnet_group.rds.name
  vpc_security_group_ids = [aws_security_group.rds.id]

  parameter_group_name   = aws_db_parameter_group.postgres.name

  backup_retention_period = var.backup_retention
  deletion_protection     = var.deletion_protection

  publicly_accessible = false
  skip_final_snapshot = true

  tags = {
    Name = "${var.project_name}-postgres"
  }
}

