resource "aws_autoscaling_group" "default" {
  name                = "asg-${var.workload}"
  min_size            = 1
  max_size            = 3
  desired_capacity    = 3
  vpc_zone_identifier = [var.subnet_id]

  launch_template {
    id      = aws_launch_template.main.id
    version = "$Latest"
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_iam_instance_profile" "default" {
  name = "ssm-asg-${var.workload}"
  role = aws_iam_role.main.id
}

resource "aws_launch_template" "main" {
  name          = "launchtemplate-${var.workload}"
  image_id      = var.ami
  user_data     = filebase64("${path.module}/asg.sh")
  instance_type = var.instance_type
  key_name      = var.key_name

  iam_instance_profile {
    arn = aws_iam_instance_profile.default.arn
  }

  metadata_options {
    http_endpoint = "enabled"
    http_tokens   = "required"
  }

  monitoring {
    enabled = false
  }

  block_device_mappings {
    device_name = "/dev/sda1"

    ebs {
      volume_size = 20
      volume_type = "gp3"
    }
  }

  network_interfaces {
    associate_public_ip_address = true
    security_groups             = [aws_security_group.elb.id]
    delete_on_termination       = true
  }

  tag_specifications {
    resource_type = "instance"

    tags = {
      Name    = "ssm-asg-instance"
      Cluster = "ASG"
    }
  }
}

resource "aws_iam_role" "main" {
  name = "ssm-asg-${var.workload}"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      },
    ]
  })
}

resource "aws_iam_role_policy_attachment" "ssm-managed-instance-core" {
  role       = aws_iam_role.main.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

data "aws_vpc" "selected" {
  id = var.vpc_id
}

locals {
  vpc_cidr_blocks = [data.aws_vpc.selected.cidr_block]
}

resource "aws_security_group" "elb" {
  name   = "ssm-asg-${var.workload}"
  vpc_id = var.vpc_id
}

resource "aws_security_group_rule" "outbound_http" {
  description       = "HTTP Outbound"
  type              = "egress"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.elb.id
}

resource "aws_security_group_rule" "outbound_https" {
  description       = "HTTPS Outbound"
  type              = "egress"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.elb.id
}
