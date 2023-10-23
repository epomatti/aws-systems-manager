locals {
  user_data = "${path.module}/userdata/${var.user_data_file}"
}

resource "aws_instance" "default" {
  ami           = var.ami
  instance_type = var.instance_type

  associate_public_ip_address = true
  subnet_id                   = var.subnet_id
  vpc_security_group_ids      = [var.security_group_id]
  iam_instance_profile        = var.iam_instance_profile_id
  key_name                    = var.key_name

  user_data = file(local.user_data)

  metadata_options {
    http_endpoint = "enabled"
    http_tokens   = "required"
  }

  monitoring    = true
  ebs_optimized = true

  root_block_device {
    encrypted   = true
    volume_type = "gp3"

    tags = {
      "Name" = "${var.workload}-${var.instance_label}"
    }
  }

  lifecycle {
    ignore_changes = [
      ami,
      associate_public_ip_address,
      user_data
    ]
  }

  tags = {
    Name        = "${var.workload}-${var.instance_label}"
    Environment = var.environment_tag
    Platform    = var.platform_tag
  }
}
