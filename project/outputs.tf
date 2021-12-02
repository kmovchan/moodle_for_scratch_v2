output "vpc_id" {
  value = module.vpc.vpc_id
}

output "vpc_cidr" {
  value = module.vpc.vpc_cidr
}

output "public_subnet_ids" {
  value = module.vpc.public_subnet_ids
}

output "private_subnet_ids" {
  value = module.vpc.private_subnet_ids
}

output "db_subnet_ids" {
  value = module.vpc.private_subnet_ids
}

output "aws_availability_zones" {
  value = module.vpc.aws_availability_zones
}

#When using cluster mode you should use
output "elasticache_endpoint_address" {
  value = module.redis.elasticache_endpoint_address
}

#primary_endpoint_address attribute is only available for non cluster-mode
output "elasticache_host" {
  value = module.redis.elasticache_host
}

output "elasticache_replication_group_member_clusters" {
  value       = module.redis.elasticache_replication_group_member_clusters
  description = "The identifiers of all the nodes that are part of this replication group."
}

output "db_password" {
  value = module.database.db_password
  sensitive = true
}

output "db_dns_name" {
  value = module.database.db_dns_name
}

output "alb_vpl_dns_name" {
  value = module.alb_vpl.alb_vpl_dns_name
}


output "alb_external_dns_name" {
  value = module.alb_ext.alb_external_dns_name
}

output "bastion_host_public_ip" {
  value = module.bastion.bastion_public_ip
}
