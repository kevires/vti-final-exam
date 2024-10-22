# Create the security group for RDS instance
resource "aws_security_group" "sg_rds_postgres_instance" {
  vpc_id      = var.vpc_id
  name        = "SG RDS INSTANCE KHAINH"
  description = "Allow access to RDS instance from the external network"
  
  # Ingress rule to allow external access (replace with your IP or open to all cautiously)
  ingress {
    description = "Allow external access to RDS from specific IPs"
    from_port   = var.db_port
    to_port     = var.db_port
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  # Replace with your specific IP for better security
  }

  # Allow all outbound traffic
  egress {
    from_port   = 0
    to_port     = 65535
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Create the DB parameter group
resource "aws_db_parameter_group" "dbpg_rds_postgres" {
  name        = "postgres-pg-khainh"
  family      = "postgres16"
  description = "postgres16 description"
}

# Create the PostgreSQL RDS instance
resource "aws_db_instance" "rds_postgre_db" {
  identifier              = "khainh-postgres-db"
  engine                  = "postgres"
  instance_class          = var.instance_class
  db_name                 = var.db_name
  username                = var.username
  password                = var.rd_pwd_postgre
  parameter_group_name    = aws_db_parameter_group.dbpg_rds_postgres.name 
  skip_final_snapshot     = true
  
  # Enable public accessibility
  publicly_accessible     = true  # Set to true to allow external access

  storage_type            = "gp2"
  backup_retention_period = 7
  allocated_storage       = 20
  vpc_security_group_ids  = [aws_security_group.sg_rds_postgres_instance.id]  # Attach the correct security group
  availability_zone       = "ap-southeast-1a"
  db_subnet_group_name    = "khainh-subnetgr-db"  

  tags = {
    Name = "PostgreSQL-RDS"
  }
}

# Create SSM Parameters (no changes needed unless you're specifying extra details)
resource "aws_ssm_parameter" "default_postgres_ssm_parameter_identifier" {
  count = 1
  name  = format("/rds/db/%s/identifier", var.identifier_db)
  value = var.identifier_db
  type  = "String"
  overwrite = true
}

resource "aws_ssm_parameter" "default_postgres_ssm_parameter_endpoint" {
  count = 1  # Set to 1 to actually store the endpoint
  name  = format("/rds/db/%s/endpoint", var.identifier_db)
  value = aws_db_instance.rds_postgre_db.endpoint
  type  = "String"
  overwrite = true
}

resource "aws_ssm_parameter" "default_postgres_ssm_parameter_username" {
  count = 1
  name  = format("/rds/db/%s/superuser/username", var.identifier_db)
  value = var.username
  type  = "String"
  overwrite = true
}

resource "aws_ssm_parameter" "default_postgres_ssm_parameter_password" {
  count = 1
  name  = format("/rds/db/%s/superuser/password", var.identifier_db)
  value = var.rd_pwd_postgre
  type  = "String"
  overwrite = true
}

resource "aws_ssm_parameter" "default_postgres_db_name" {
  count = 1
  name  = format("/rds/db/%s/dbname", var.db_name)
  value = aws_db_instance.rds_postgre_db.db_name
  type  = "String"
  overwrite = true
}
