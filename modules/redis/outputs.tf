#When using cluster mode you should use
output "elasticache_endpoint_address" {
  value = aws_elasticache_replication_group.box_redis.configuration_endpoint_address
}

#primary_endpoint_address attribute is only available for non cluster-mode
output "elasticache_host" {
  value = aws_elasticache_replication_group.box_redis.primary_endpoint_address
}

output "elasticache_replication_group_member_clusters" {
  value       = aws_elasticache_replication_group.box_redis.member_clusters
description = "The identifiers of all the nodes that are part of this replication group."
}