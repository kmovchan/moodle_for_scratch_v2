########## Mariadb
data "aws_ssm_parameter" "rds_password" {
  name       = "/prod/mariadb-${var.env}"
  depends_on = [aws_ssm_parameter.rds_password]
}
resource "random_string" "rds_password" {
  length = 16
  #special = true
  special = false
  #override_special = "!#%&"
  #change password if variable "Name" chnages the password changes also
  # keepers = {
  #     keeper1 = "Name"
  #   }
  #
}

resource "aws_ssm_parameter" "rds_password" {
  name        = "/prod/mariadb-${var.env}"
  description = "Master"
  type        = "SecureString"
  value       = random_string.rds_password.result
}

/*
resource "aws_db_parameter_group" "default" {
  name   = "mariadb-${var.env}"
  family = "mariadb10.2"

    parameter {
      name  = "max_connections"
      value = "1024"
    }
}
*/
resource "aws_db_subnet_group" "db_subnet_group" {
  name       = "rds-subnet-group-${var.env}"
  subnet_ids = var.subnet_ids
}

resource "aws_db_instance" "dev-rds" {
  identifier        = "dev-rds"
  allocated_storage = 20
  storage_type      = "gp2"
  engine            = "mariadb"
  engine_version    = "10.4.21"
  instance_class    = var.instance_class
  name           = "moodle"
  username       = "root"
  password       = data.aws_ssm_parameter.rds_password.value
  parameter_group_name = "default.mariadb10.4"
  #parameter_group_name = "mariadb-${var.env}"
  skip_final_snapshot  = "true"
  apply_immediately    = "true"
  multi_az             = false
  maintenance_window = "Mon:00:00-Mon:03:00"
  backup_window      = "03:00-06:00"
  #  storage_encrypted    = false
  db_subnet_group_name   = aws_db_subnet_group.db_subnet_group.id
  vpc_security_group_ids = [var.mariadb_security_group_id]
  availability_zone      = var.availability_zone[0]
}