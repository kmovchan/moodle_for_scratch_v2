variable "bastion_security_group_id" {
  description = "Security Group"
}

variable "key_name" {
  description = "SSH key"
}

variable "tls_private_key" {
}

variable "public_subnet_id" {
  description = "Private subnet ids"
}
variable "db_host" {
}
variable "db_password" {
}
variable "ip_node01" {
}
variable "ip_node02" {
}
