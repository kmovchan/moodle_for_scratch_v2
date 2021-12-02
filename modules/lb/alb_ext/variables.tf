variable "bastion_security_group_id" {
  description = "Security Group for ASG"
}

variable "alb_security_group_id" {
  default = "Security Group for ALB"
}

variable "key_name" {
  description = "SSH key"
}
variable "public_subnet_ids" {
  description = "Public subnet ids"
}
variable "private_subnet_ids" {
  description = "Public subnet ids"
}

variable "instance_type" {
  description = "aim type"
  default     = "t2.micro"
}

variable "env" {
  default = "dev"
}

variable "vpc_id" {
  default = "vpc id"
}
variable "db_host" {
}
variable "db_password" {
}
variable "ip_node01" {
}
variable "ip_node02" {
}

variable "ami_name" {
}
variable "redis" {
}