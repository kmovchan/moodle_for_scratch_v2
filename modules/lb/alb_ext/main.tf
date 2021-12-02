data "aws_ami" "latest_image_moodle" {
  owners = ["self"]
  ##  owners      = ["760354315822"]
  most_recent = true
  filter {
    name = "name" 
    values = [var.ami_name]
  }
}
resource "random_pet" "pet_name" {
  length = 2
}


data "template_file" "user_data" {
  template = file("${path.module}/user_data.tpl")

  vars = {
    db_host               = element(split(":", var.db_host), 0)
    db_password           = var.db_password
    wwwroot               = aws_lb.TestALB.dns_name
    dataroot              = "/mnt/efs/html/moodledata"
    ssm_cloudwatch_config = aws_ssm_parameter.cw_agent.name
    ip_node01             = var.ip_node01
    ip_node02             = var.ip_node02
    redis                 = var.redis
  }
}

resource "aws_ssm_parameter" "cw_agent" {
  description = "Cloudwatch agent config"
  name        = "/cloudwatch-agent/config"
  type        = "String"
  value       = file("${path.module}/cloudwatch/config.json")
}
############ IAM

resource "aws_iam_instance_profile" "moodle_asg_profile" {
  name = "${random_pet.pet_name.id}_asg_profile"
  role = aws_iam_role.moodle_asg_role.name
}

resource "aws_iam_role" "moodle_asg_role" {
  name = "${random_pet.pet_name.id}_asg_role"
  path = "/"

  assume_role_policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Action": "sts:AssumeRole",
            "Principal": {
               "Service": "ec2.amazonaws.com"
            },
            "Effect": "Allow",
            "Sid": ""
        }
    ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "moodle_role_attachment" {
  role       = aws_iam_role.moodle_asg_role.name
  policy_arn = aws_iam_policy.moodle_asg_policy.arn
}

resource "aws_iam_policy" "moodle_asg_policy" {
  name   = "access_asg_${random_pet.pet_name.id}"
  path   = "/"
  policy = data.aws_iam_policy_document.moodle_asg_policy_doc.json
}

data "aws_iam_policy_document" "moodle_asg_policy_doc" {
  statement {
    sid = "AllowCloudWatching"

    actions = [
      "cloudwatch:*",
    ]

    resources = [
      "*",
    ]
  }
}

############ Create  AutoScaling SecurityGroup
resource "aws_launch_configuration" "box-dev" {
  name_prefix = "moodle-${var.env}-app-"
  image_id             = data.aws_ami.latest_image_moodle.id
  iam_instance_profile = aws_iam_instance_profile.moodle_asg_profile.name
  instance_type        = var.instance_type
  key_name             = var.key_name
  enable_monitoring    = true
  user_data       = base64encode(data.template_file.user_data.rendered)
  security_groups = [var.bastion_security_group_id]


  connection {
    type = "ssh"
    user = "ubuntu"
    private_key = file("~/Downloads/aws-test.pem")
    host        = self.public_ip

  }
  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_group" "box-asg" {
  name_prefix          = "ASG-${aws_launch_configuration.box-dev.name}-"
  depends_on           = [aws_launch_configuration.box-dev]
  launch_configuration = aws_launch_configuration.box-dev.name
  min_size             = 2
  max_size             = 10
  health_check_type    = "EC2"
  force_delete         = true
  termination_policies = ["NewestInstance"]
  vpc_zone_identifier  = var.private_subnet_ids
  #vpc_zone_identifier = [aws_subnet.public_subnets[0].id, aws_subnet.public_subnets[1].id]
  target_group_arns = [aws_alb_target_group.boxui.arn]

  dynamic "tag" {
    for_each = {
      Name   = "Moodle in ASG"
      TAGKEY = "TAGVALUE"
    }
    content {
      key                 = tag.key
      value               = tag.value
      propagate_at_launch = true
    }
  }

  lifecycle {
    create_before_destroy = true
    ignore_changes = [load_balancers, target_group_arns]
  }
}

# -------------- Create a new Application load balancer
resource "aws_lb" "TestALB" {
  name               = "alb-${var.env}"
  load_balancer_type = "application"
  #subnets            = aws_subnet.public_subnets.*.id
  subnets      = var.public_subnet_ids
  internal     = false
  idle_timeout = "300"
  #enable_deletion_protection = false
  enable_http2    = true
  security_groups = [var.alb_security_group_id]

  ##enable_deletion_protection = true

}

#########Default Listener
resource "aws_lb_listener" "TestALB-HTTP" {
  load_balancer_arn = aws_lb.TestALB.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_alb_target_group.boxui.arn
  }
}

###########Disable Certificate Listener
/*
#------------- Define a listener
resource "aws_alb_listener" "TestALB-HTTP" {
  load_balancer_arn = aws_lb.TestALB.arn
  port              = "80"
  protocol          = "HTTP"
  #  ssl_policy        = "ELBSecurityPolicy-2015-05"
  #  certificate_arn   = "${var.ssl_arn}"

  default_action {
    type = "redirect"

    redirect {
      port     = "80"
      protocol = "HTTP"
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }
}

resource "aws_lb_listener" "TestALB-HTTPS" {
  load_balancer_arn = aws_lb.TestALB.arn
  port              = "443"
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2016-08"
  certificate_arn   = "arn:aws:iam::886853674074:server-certificate/Univ"

  default_action {
    type = "fixed-response"

    fixed_response {
      content_type = "text/plain"
      message_body = "Authenticate required"
      status_code  = "403"
    }
  }
}

resource "aws_lb_listener_rule" "box-nginx" {
  listener_arn = aws_lb_listener.TestALB-HTTPS.arn
  priority     = "1"
  action {
    type             = "forward"
    target_group_arn = aws_alb_target_group.boxui.arn
  }
  condition {
    path_pattern {
      values = ["/*"]
    }
  }
}
*/
# ----------- target Group
resource "aws_alb_target_group" "boxui" {
  name     = "boxui-dev"
  port     = 80
  protocol = "HTTP"
  vpc_id   = var.vpc_id
  stickiness {
    type = "lb_cookie"
  }
  health_check {
    enabled  = true
    path     = "/"
    port     = "80"
    protocol = "HTTP"
    interval = "60"
    matcher  = "200-301"
    timeout  = "10"
  }

  lifecycle { create_before_destroy=true }
}

#-------- AutoScaling policy -------
resource "aws_autoscaling_policy" "web_policy_up" {
  name        = "CPUReservation-Scale-up"
  policy_type = "StepScaling"
  adjustment_type    = "ChangeInCapacity"
  #adjustment_type        = "PercentChangeInCapacity"
  autoscaling_group_name = aws_autoscaling_group.box-asg.name
  #element(aws_autoscaling_group.box-asg.*.name, count.index)
  estimated_instance_warmup = 60


  step_adjustment {
    scaling_adjustment          = 0
    metric_interval_lower_bound = 0
    metric_interval_upper_bound = 10
  }

  step_adjustment {
    scaling_adjustment          = 2
    metric_interval_lower_bound = 10
    metric_interval_upper_bound = 20
  }

  step_adjustment {
    scaling_adjustment          = 2
    metric_interval_lower_bound = 20
    metric_interval_upper_bound = null
  }
  #min_adjustment_magnitude  = 2
}

resource "aws_autoscaling_policy" "web_policy_down" {
  name                   = "CPUReservation-Scale-Down"
  policy_type            = "StepScaling"
  adjustment_type    = "ChangeInCapacity"
  #adjustment_type        = "PercentChangeInCapacity"
  autoscaling_group_name = aws_autoscaling_group.box-asg.name
  #element(aws_autoscaling_group.box-asg.*.name, count.index)
  estimated_instance_warmup = 60


  step_adjustment {
    scaling_adjustment          = -1
    metric_interval_lower_bound = -10
    metric_interval_upper_bound = 0
  }

  step_adjustment {
    scaling_adjustment          = -1
    metric_interval_lower_bound = -20
    metric_interval_upper_bound = -10
  }

  step_adjustment {
    scaling_adjustment          = -2
    metric_interval_lower_bound = null
    metric_interval_upper_bound = -20
  }

}
resource "aws_cloudwatch_metric_alarm" "web_cpu_alarm_up" {
  alarm_name          = "web_cpu_alarm_up"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "1"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = "60"
  statistic           = "Average"
  threshold           = "50"

  dimensions = {
    "AutoScalingGroupName" = aws_autoscaling_group.box-asg.name
    #"AutoScalingGroupName" = element(aws_autoscaling_group.box-asg.*.name, count.index)
  }
  actions_enabled   = true
  alarm_description = "This metric monitor EC2 instance CPU utilization"
  alarm_actions     = [aws_autoscaling_policy.web_policy_up.arn]
  #alarm_actions = [element(aws_autoscaling_policy.web_policy_up.*.arn, count.index)]
}

resource "aws_cloudwatch_metric_alarm" "web_cpu_alarm_down" {
  alarm_name          = "web_cpu_alarm_down"
  comparison_operator = "LessThanOrEqualToThreshold"
  evaluation_periods  = "1"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = "60"
  statistic           = "Average"
  threshold           = "50"

  dimensions = {
    #AutoScalingGroupName = element(aws_autoscaling_group.box-asg.*.name, count.index)
    "AutoScalingGroupName" = aws_autoscaling_group.box-asg.name
  }
  actions_enabled   = true
  alarm_description = "This metric monitor EC2 instance CPU utilization"
  #alarm_actions     = [element(aws_autoscaling_policy.web_policy_down.*.arn, count.index)]
  alarm_actions = [aws_autoscaling_policy.web_policy_down.arn]
}
