variable "node_type" {
  description = "redis node type"
  default = "cache.t3.small"
}
variable "subnet_ids" {
    type        = list
  description = "Subnet ids"
}
variable "redis_security_group_id" {
    description = "Security Group"
}

variable "env" { 
}