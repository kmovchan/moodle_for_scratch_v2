data "aws_ami" "latest_ubuntu" {
  owners      = ["099720109477"]
  most_recent = true
  filter {
    name   = "name"
    #values = ["ubuntu/images/*ubuntu-focal-20.04-amd64-server-*"]
    values = ["ubuntu/images/hvm-ssd/ubuntu-bionic-18.04-amd64-server-*"]
  }
}

data "template_file" "gluster_data" {
  template = file("${path.module}/gluster_data.tpl")

}

############## Create Gluster nodes ########
resource "aws_instance" "gluster_nodes" {
  count     = length(var.private_subnet_ids)
  ami       = data.aws_ami.latest_ubuntu.id
  subnet_id = element(var.private_subnet_ids, count.index)
  instance_type          = var.instance_type
  vpc_security_group_ids = [var.gluster_security_group_id]
  key_name               = var.key_name
  user_data              = data.template_file.gluster_data.rendered

  tags = {
    Name = "gluster_nodes"
  }
}

resource "aws_ebs_volume" "gluster_volume" {
  count             = length(var.private_subnet_ids)
  availability_zone = var.availability_zones[count.index]
  size              = var.ebs_volume_size
  tags = {
    Name = "ebs-vol"
  }
}

resource "aws_volume_attachment" "attach_gluster_volume" {
  count        = 2
  device_name  = "/dev/sdh"
  volume_id    = aws_ebs_volume.gluster_volume[count.index].id
  instance_id  = aws_instance.gluster_nodes[count.index].id
  force_detach = true
  depends_on   = [aws_ebs_volume.gluster_volume]
}
