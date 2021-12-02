variable "instance_class" {
  description = "redis node type"
  default     = "db.t3.small"
}
variable "subnet_ids" {
    type        = list
  description = "Subnet ids"
}
variable "mariadb_security_group_id" {
    description = "Security Group"
}

variable "availability_zone" {
  description = "availability_zones"
}
variable "env" {
}