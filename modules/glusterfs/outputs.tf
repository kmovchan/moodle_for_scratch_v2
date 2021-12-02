output "ip_node01" {
  value = aws_instance.gluster_nodes.0.private_ip
}

output "ip_node02" {
 value =  aws_instance.gluster_nodes.1.private_ip
}