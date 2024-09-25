variable "vpc_id" {
  description = "The VPC ID where the app instance will be deployed"
}

variable "public_subnet" {
  description = "The public subnet IDs for the ALB"
  type        = list(string)
}

variable "private_subnet_a" {
  description = "The private subnet ID for the app instance"
}

variable "alb_security_group_id" {
  description = "The security group ID for the ALB"
}

variable "web_security_group_id" {
  description = "The security group ID for the web instance"
}

resource "tls_private_key" "example" {
  algorithm = "RSA"
  rsa_bits  = 2048
}

resource "aws_key_pair" "app_key" {
  key_name   = "my-key"
  public_key = tls_private_key.example.public_key_openssh

  tags = {
    Name = "App Key Pair"
  }
}

resource "local_file" "private_key_pem" {
  content  = tls_private_key.example.private_key_pem
  filename = "${path.module}/my-key.pem"
}

data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

# ALB 생성
resource "aws_lb" "app_lb" {
  name               = "app-load-balancer"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [var.alb_security_group_id]
  subnets            = var.public_subnet  # 두 개 이상의 서브넷을 제공해야 함

  tags = {
    Name = "App Load Balancer"
  }
}

resource "aws_lb_target_group" "app_tg" {
  name     = "app-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = var.vpc_id

  tags = {
    Name = "App Target Group"
  }
}

resource "aws_lb_listener" "app_listener" {
  load_balancer_arn = aws_lb.app_lb.arn
  port              = 80
  protocol          = "HTTP"
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.app_tg.arn
  }
}

# EC2 인스턴스 생성 및 private subnet에 배치
resource "aws_instance" "web" {
  ami           = data.aws_ami.amazon_linux.id
  instance_type = "t2.micro"
  subnet_id     = var.private_subnet_a
  key_name      = aws_key_pair.app_key.key_name
  security_groups = [var.web_security_group_id]

  tags = {
    Name = "Web Server"
  }
}

resource "aws_lb_target_group_attachment" "web_attachment" {
  target_group_arn = aws_lb_target_group.app_tg.arn
  target_id        = aws_instance.web.id
  port             = 80
}


output "alb_dns_name" {
  value = aws_lb.app_lb.dns_name
}

