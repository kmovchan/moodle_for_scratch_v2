data "aws_ami" "latest_ubuntu" {
  owners      = ["099720109477"]
  most_recent = true
  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-bionic-18.04-amd64-server-*"]
  }
}

data "template_file" "bastion_data" {
  template = file("${path.module}/bastion_data.tpl")

  vars = {
    #db_host     = aws_db_instance.dev-rds.endpoint
    #db_host = "${element(split(":", aws_db_instance.dev-rds.endpoint), 0)}"
    db_host     = element(split(":", var.db_host), 0)
    db_password = var.db_password
    ip_node01   = var.ip_node01
    ip_node02   = var.ip_node02
  }
}

############## Create Bastion host ########
resource "aws_instance" "bastion" {
  ami = data.aws_ami.latest_ubuntu.id
  #subnet_id = var.private_subnet_ids[0]
  subnet_id              = var.public_subnet_id
  instance_type          = "t3.micro"
  vpc_security_group_ids = [var.bastion_security_group_id]
  key_name               = var.key_name
  user_data              = data.template_file.bastion_data.rendered
  tags = {
    Name = "bastion"
  }

  connection {
    type = "ssh"
    user = "ubuntu"
    #private_key = "${file("~/.ssh/id_rsa")}"
    private_key = chomp(var.tls_private_key)
    #private_key = file("../keys/aws-test2.pem")
    host        = self.public_ip
  }
  provisioner "file" {
    source      = "${path.module}/ansible/playbook.yml"
    destination = "./playbook.yml"
  }

  provisioner "file" {
    source      = "${path.module}/ansible/gluster.yml"
    destination = "./gluster.yml"
  }
  provisioner "file" {
    source      = "${path.module}/ansible/ganesha.conf.j2"
    destination = "./ganesha.conf.j2"
  }

  provisioner "file" {
    #source      = "../keys/aws-test2.pem"
    #content      =  chomp(var.tls_private_key)
    content       = var.tls_private_key
    destination = "./aws-test.pem"
  }

  provisioner "remote-exec" {
    inline = [
      "chmod 600 ./aws-test.pem"
    ]
  }
}
