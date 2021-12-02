# Generates RSA Keypair
resource "tls_private_key" "task_key" {
#  count = var.create_key_pair ? 1 : 0
  algorithm = "RSA"
  rsa_bits  = 4096
}

# Save Private key locally
 resource "local_file" "private_key_pem" {
   depends_on = [tls_private_key.task_key]
   content  = tls_private_key.task_key.private_key_pem
   filename = "../keys/${var.key_name}.pem"
   file_permission = "600"
 }

resource "local_file" "public_key_pem" {
  depends_on = [tls_private_key.task_key]
  content    = tls_private_key.task_key.public_key_openssh
  filename   = "../keys/${var.key_name}.pub"
}

resource "aws_key_pair" "task_key" {
  key_name   = var.key_name
  public_key = tls_private_key.task_key.public_key_openssh
}
