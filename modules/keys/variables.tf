variable "key_name" {
  description = "SSH key"
}

variable "create_key_pair" {
  description = "Controls if key pair should be created"
  type        = bool
  default     = true
}