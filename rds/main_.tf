# #create the security group for rds instance
# resource "aws_security_group" "sg_rds_postgres_instance" {
#   vpc_id      = var.vpc_id
#   name        = "SG RDS INSTANCE"
#   description = "Allow app can access into the rds instance"
#   ingress {
#     description = "Allow all subnet in the vpc can accessable"
#     from_port   = var.db_port
#     to_port     = var.db_port
#     protocol    = "tcp"
#   }
#   egress {
#     from_port   = 0
#     to_port     = 65535
#     protocol    = "tcp"
#     cidr_blocks = ["0.0.0.0/0"]
#   }
# }

# #crate the db parameter group
# resource "aws_db_parameter_group" "dbpg_rds_postgres" {
#   name        = "postgres-pg"
#   family      = "postgres16"
#   description = "postgres13 description"
# }


# #create the postgresql
# resource "aws_db_instance" "rds_postgre_db" {
#   identifier              = "khainh-postgres-db"
#   engine                  = "postgres"
#   instance_class          = var.instance_class
#   db_name                 = var.db_name
#   username                = var.username
#   password                = var.rd_pwd_postgre
#   parameter_group_name    = aws_db_parameter_group.dbpg_rds_postgres.name # Adjust if using a different version
#   skip_final_snapshot     = true
#   publicly_accessible     = false
#   storage_type            = "gp2"
#   backup_retention_period = 7
#   allocated_storage = 20
#   vpc_security_group_ids = ["sg-0a24c8d4d370185ae"]
#   availability_zone = "ap-southeast-1a"
#   db_subnet_group_name    = "khainh_db_subnet_group"  # Thay bằng tên DB Subnet Group bạn đã lấy

#   tags = {
#     Name = "PostgreSQL-RDS"
#   }

# }

# #creat the ssm
# resource "aws_ssm_parameter" "default_postgres_ssm_parameter_identifier" {
#   count = 1
#   name  = format("/rds/db/%s/identifier", var.identifier_db)
#   value = var.identifier_db
#   type  = "String"
# }

# resource "aws_ssm_parameter" "default_postgres_ssm_parameter_endpoint" {
#   count = 0
#   name  = format("/rds/db/%s/endpoint", var.identifier_db)
#   value = aws_db_instance.rds_postgre_db.endpoint
#   type  = "String"
# }

# resource "aws_ssm_parameter" "default_postgres_ssm_parameter_username" {
#   count = 1
#   name  = format("/rds/db/%s/superuser/username", var.identifier_db)
#   value = var.username
#   type  = "String"
# }

# resource "aws_ssm_parameter" "default_postgres_ssm_parameter_password" {
#   count = 1
#   name  = format("/rds/db/%s/superuser/password", var.identifier_db)
#   value = aws_db_instance.rds_postgre_db.password
#   type  = "String"
# }
# resource "aws_ssm_parameter" "default_postgres_db_name" {
#   count = 1
#   name  = format("/rds/db/%s/dbname", var.db_name)
#   value = aws_db_instance.rds_postgre_db.password
#   type  = "String"
# }
