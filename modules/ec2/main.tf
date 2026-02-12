data "aws_ssm_parameter" "amazon_linux" {
  name = "/aws/service/ami-amazon-linux-latest/al2023-ami-kernel-default-x86_64"
}

resource "aws_launch_template" "this" {
  name_prefix   = var.name
  image_id      = data.aws_ssm_parameter.amazon_linux.value
  instance_type = var.instance_type
  vpc_security_group_ids = [aws_security_group.ec2.id]
  user_data     = base64encode(<<-EOT
    #!/bin/bash
    set -euo pipefail

    dnf -y update
    dnf -y install httpd
    systemctl enable --now httpd

    echo "Hello from ${var.name}!" > /var/www/html/index.html
  EOT
  )
}


resource "aws_security_group" "ec2" {
  vpc_id = var.vpc_id

  ingress {
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [var.alb_sg_id]
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = var.ssh_cidr_blocks
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# resource "aws_launch_template" "thiss" {
#   name_prefix   = var.name
#   image_id      = var.ami_id
#   instance_type = var.instance_type
# }

resource "aws_autoscaling_group" "this" {
  min_size            = 1
  max_size            = 3
  desired_capacity    = 2
  vpc_zone_identifier = var.public_subnets

  launch_template {
    id      = aws_launch_template.this.id
    version = "$Latest"
  }

  target_group_arns = [var.target_group_arn]
}
