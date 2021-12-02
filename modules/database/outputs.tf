output "db_password" {
  value = data.aws_ssm_parameter.rds_password.value

}

output "db_dns_name" {
  value = aws_db_instance.dev-rds.endpoint
}
##it's new just Test it !!!
/*
output "db_address" {
  value       = aws_db_instance.dev-rds.address
  description = "Connect to the database at this endpoint"
}
output "db_port" {
  value       = aws_db_instance.dev-rds.port
  description = "The port the database is listening on"
}
*/