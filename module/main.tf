resource "aws_instance" "instance" {
  ami                    = data.aws_ami.ami.image_id
  instance_type          = var.instance_type
  vpc_security_group_ids = [data.aws_security_group.selected.id]
  iam_instance_profile   = aws_iam_instance_profile.instance_profile.name

  instance_market_options {
    market_type = "spot"
    spot_options {
      instance_interruption_behavior = "stop"
      spot_instance_type             = "persistent"
    }
  }

  tags = {
    Name = var.application_name
  }

  lifecycle {
    ignore_changes = [
      ami,
    ]
  }
}

resource "aws_route53_record" "record" {
  name    = var.application_name
  zone_id = var.zone_id
  type    = "A"
  ttl     = 30
  records = [aws_instance.instance.public_ip]
}

resource "aws_route53_record" "record-internal" {
  name    = "${var.application_name}-internal"
  zone_id = var.zone_id
  type    = "A"
  ttl     = 30
  records = [aws_instance.instance.private_ip]
}

resource "aws_iam_role" "role" {
  name = "${var.application_name}-role"

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

  inline_policy {
    name = "${var.application_name}-inline-policy"

    policy = jsonencode({
      Version = "2012-10-17"
      Statement = [
        {
          Action   = concat(var.dummy_policy, var.policy_resource_list)
          Effect   = "Allow"
          Resource = "*"
      },
    ]
  })
}

tags = {
  Name = "${var.application_name}-role"
}
}

resource "aws_iam_instance_profile" "instance_profile" {
name = "${var.application_name}-role"
role = aws_iam_role.role.name
}