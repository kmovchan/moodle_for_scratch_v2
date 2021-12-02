
output "bastion_public_ip" {
  value = aws_instance.bastion.public_ip
}

#output "multi_gluster_private_ips" {
#  value = aws_instance.gluster_nodes[*].private_ip
#}