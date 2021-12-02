output "vpc_id" {
  value = aws_vpc.main.id
}

output "vpc_cidr" {
  value = aws_vpc.main.cidr_block
}

output "public_subnet_ids" {
  value = aws_subnet.public_subnets[*].id
}

output "private_subnet_ids" {
  value = aws_subnet.private_subnets[*].id
}

output "db_subnet_ids" {
  value = aws_subnet.private_subnets[*].id
}

output "aws_availability_zones" {
  value = data.aws_availability_zones.available.names
}

output "redis_security_group_id" {
  value = aws_security_group.allow_redis.id
}

output "mariadb_security_group_id" {
  value = aws_security_group.allow_mysql.id
}
output "bastion_security_group_id" {
  value = aws_security_group.box-dev.id
}
output "gluster_security_group_id" {
  value = aws_security_group.glusterfs.id
}
output "alb_vpl_security_group_id" {
  value = aws_security_group.alb_vpl.id
}

output "alb_security_group_id" {
  value = aws_security_group.alb_box-dev.id
}
