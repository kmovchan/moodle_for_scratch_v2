
data "aws_ami" "latest_ubuntu" {
  owners      = ["099720109477"]
  most_recent = true
  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-bionic-18.04-amd64-server-*"]
  }
}
data "aws_ami" "latest_image_vpl" {
  owners = ["self"]
  ##  owners      = ["760354315822"]
  most_recent = true
  filter {
    name = "name" 
    #values = ["ubuntu2004-moodle389-new"]
    values = [var.ami_name]
  }
}

########### Create Internal  AutoScaling
resource "aws_launch_configuration" "vpl-internal" {
  name_prefix = "vpl-internal-app-"
  #image_id    = var.ami_name
  image_id =  data.aws_ami.latest_image_vpl.id
  instance_type = var.instance_type
  key_name      = var.key_name
  security_groups = [var.alb_vpl_security_group_id]
  
  lifecycle {
    create_before_destroy = true
  }

}
  


resource "aws_autoscaling_group" "vpl-internal-asg" {
  name_prefix          = "ASG-${aws_launch_configuration.vpl-internal.name}-"
  depends_on           = [aws_launch_configuration.vpl-internal]
  launch_configuration = aws_launch_configuration.vpl-internal.name
  min_size             = 1
  max_size             = 2
  health_check_type    = "EC2"
  force_delete         = true
  termination_policies = ["NewestInstance"]
  vpc_zone_identifier  = var.private_subnet_ids

  #vpc_zone_identifier = [aws_subnet.public_subnets[0].id, aws_subnet.public_subnets[1].id]
  target_group_arns = [aws_lb_target_group.vpl-target.arn]
  enabled_metrics   = ["GroupDesiredCapacity", "GroupInServiceCapacity", "GroupMinSize", "GroupMaxSize", "GroupInServiceInstances", "GroupTotalCapacity", "GroupTotalInstances"]
  
  lifecycle {
    create_before_destroy = true
    ignore_changes        = [load_balancers, target_group_arns]
  }

  dynamic "tag" {
    for_each = {
      Name   = "VPL in ASG"
      TAGKEY = "TAGVALUE"
    }
    content {
      key                 = tag.key
      value               = tag.value
      propagate_at_launch = true
    }
  }    
}

# -------------- Create a VPL Application load balancer
resource "aws_lb" "vpl-alb" {
  name               = "vpl-alb-${var.env}"
  load_balancer_type = "application"
  subnets            = var.public_subnet_ids
  internal     = false
  idle_timeout = "300"
  enable_http2 = true
  security_groups = [var.alb_vpl_security_group_id]
  ##enable_deletion_protection = true

}


#########Default Listener
resource "aws_lb_listener" "VPL-NLB-HTTP" {
  load_balancer_arn = aws_lb.vpl-alb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.vpl-target.arn
  }
}


# ----------- target Group
resource "aws_lb_target_group" "vpl-target" {
  name     = "vpl-target"
  port     = 80
  protocol = "HTTP"
  vpc_id   = var.vpc_id
   
  health_check {
    enabled  = true
    path     = "/"
    port     = "80"
    protocol = "HTTP"
    interval = "60"
    matcher  = "200-301"
    timeout  = "10"
  }

  lifecycle {
    create_before_destroy = true
  }
}
