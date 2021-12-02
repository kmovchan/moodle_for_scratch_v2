variable "alb_vpl_security_group_id" {
  description = "Security Group"
}

variable "key_name" {
  description = "SSH key"
}

variable "public_subnet_ids" {
  description = "Public subnet ids"
}
variable "private_subnet_ids" {
  description = "Private subnet ids"
}

variable "instance_type" {
  description = "aim type"
  default     = "t2.micro"
}

variable "vpc_id" {
  default = "vpc id"
}

variable "env" {
  default = "dev"
}
variable "ami_name" {
}
