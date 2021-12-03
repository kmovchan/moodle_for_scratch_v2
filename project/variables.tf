variable "env" {
  default = "stage"
}

variable "domain" {
  default = "moodle.eleks.com"
}

variable "vpc_cidr" {
  default = "172.22.0.0/16"
}

variable "public_subnet_cidrs" {
  default = [
    "172.22.1.0/24",
    "172.22.2.0/24",
  ]
}

variable "private_subnet_cidrs" {
  default = [
    "172.22.11.0/24",
    "172.22.12.0/24",
  ]
}

variable "db_subnet_cidrs" {
  default = [
    "172.22.21.0/24",
    "172.22.22.0/24",
  ]
}
variable "create_key_pair" {
  description = "Controls if key pair should be created"
  type        = bool
  default     = true
}

variable "instance_type" {
  description = "Moodle aim type"
  default     = "t3.xlarge"
  #default     = "m6g.xlarge"
}

variable "vpl_instance_type" {
  description = "VPL servser aim type"
  default     = "t3.small"
}

variable "gluster_instance_type" {
  description = "Glusterfs aim type"
  default     = "t3.small"
}

variable "db_instance_class" {
  description = "DB type"
  default = "db.m6g.xlarge"
}

variable "redis_node_type" {
  description = "Redis nodes type"
  default     = "cache.t3.small"
}

variable "key_name" {
  default = "aws-test2"
}

variable "vpl_ami_name" { 
  default = "vpl-server*" 
  }
variable "moodle_ami_name" { 
  default = "moodle-server*"
}
