resource "aws_elasticache_subnet_group" "redis_subnet_group" {
  name       = "redis-subnet-group-${var.env}"
  subnet_ids = var.subnet_ids
  #subnet_ids = [module.vpc-dev.private_subnet_ids[0], module.vpc-dev.private_subnet_ids[1]]
}
/*
resource "aws_elasticache_cluster" "example" {
  cluster_id           = "cluster-example"
  engine               = "redis"
  node_type            = "cache.t2.micro"
  num_cache_nodes      = 2
  parameter_group_name = "default.redis5.0"
  engine_version       = "5.0.6"
  port                 = 6379
  apply_immediately    = true

  subnet_group_name    = aws_elasticache_subnet_group.redis_subnet_group.name
}
*/
resource "aws_elasticache_replication_group" "box_redis" {
  automatic_failover_enabled = true
  ##availability_zones            = [data.aws_availability_zones.available.names[0], data.aws_availability_zones.available.names[1]]
  replication_group_id          = "tf-rep-group-${var.env}"
  replication_group_description = "test description"
  node_type             = var.node_type
  number_cache_clusters = 2
  engine                = "redis"
  engine_version        = "5.0.6"
  subnet_group_name     = aws_elasticache_subnet_group.redis_subnet_group.name
  security_group_ids = [var.redis_security_group_id]
  #security_group_ids    = [aws_security_group.allow_redis.id]
  #parameter_group_name          = "default.redis5.0"
  #transit_encryption_enabled = true
  #auth_token                 = data.aws_ssm_parameter.rds_password.value
  port = 6379
}

/*
resource "aws_elasticache_replication_group" "box_redis" {
  automatic_failover_enabled = true
  ##availability_zones            = [data.aws_availability_zones.available.names[0], data.aws_availability_zones.available.names[1]]
  replication_group_id          = "tf-rep-group-1"
  replication_group_description = "test description"
  node_type                     = "cache.t2.micro"
  ##number_cache_clusters         = 2
  engine            = "redis"
  engine_version    = "5.0.6"
  subnet_group_name = aws_elasticache_subnet_group.redis_subnet_group.name
  security_group_ids =
  #parameter_group_name          = "default.redis5.0"
  port = 6379

  #parameter_group_name =default.redis6.x default.redis5.0
  cluster_mode {
    replicas_per_node_group = 1
    num_node_groups         = 2
  }
  ##lifecycle {
  ##  ignore_changes = ["number_cache_clusters"]
  ##}
}
*/
/*
resource "aws_elasticache_cluster" "replica" {
  count = 1

  cluster_id           = "tf-rep-group-1-${count.index}"
  replication_group_id = aws_elasticache_replication_group.example-1.id
}
*/