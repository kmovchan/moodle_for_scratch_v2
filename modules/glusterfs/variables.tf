variable "instance_type" {
  description = "aim type"
  default     = "t2.micro"
}

variable "key_name" {
  description = "SSH key"
}


variable "private_subnet_ids" {
  description = "Private subnet ids"
} 
variable "ebs_volume_size" {
    description = "Size of ebs Volume for Gluster nodes"
    default = 1
  
}
variable "availability_zones" {
  description = "availability_zones"
}
variable "gluster_security_group_id" {
    description = "Security Group"
}