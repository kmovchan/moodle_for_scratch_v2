variable "region" {
  description = "Region"
  default     = "eu-west-1"
  #default = "eu-central-1"
}

variable "vpc_cidr" {
  default = "172.22.0.0/16"
}

variable "env" {
  default = "dev"
}

variable "domain" {
  default = "moodle.eleks.com"
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

variable "instance_type" {
  description = "aim type"
  default     = "t2.micro"
  #default = "t3.small"

}

variable "key_name" {
  default = "aws-test"
}

variable "allow_networks" {
  default = [
    "193.105.219.0/24",
    "217.9.3.0/24",
    "185.176.121.0/24",
  ]
}

variable "allow_ports" {
  description = "List of open ports for Server"
  type        = list(any)
  default     = ["80", "443"]

}

variable "allow_ext_ports" {
  description = "List of open ports for ALB"
  type        = list(any)
  default     = ["80", "443"]

}


variable "enable_detailed_monitoring" {
  type    = bool
  default = "false"
}

variable "common_tags" {
  description = "Common Tags to apply to all resource"
  type        = map(any)
  default = {
    Owner       = "BOX"
    Project     = "Phoenix"
    CostCenter  = "New01"
    Environment = "Development"
  }
}
