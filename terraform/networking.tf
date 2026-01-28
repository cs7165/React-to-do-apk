# VPC
resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name = "${var.app_name}-vpc"
  }
}

# Internet Gateway
resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "${var.app_name}-igw"
  }
}

# Public Subnet
resource "aws_subnet" "public" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.public_subnet_cidr
  availability_zone       = data.aws_availability_zones.available.names[0]
  map_public_ip_on_launch = true

  tags = {
    Name = "${var.app_name}-public-subnet"
  }
}

# Route Table
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block      = "0.0.0.0/0"
    gateway_id      = aws_internet_gateway.main.id
  }

  tags = {
    Name = "${var.app_name}-public-rt"
  }
}

# Route Table Association
resource "aws_route_table_association" "public" {
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.public.id
}

# Security Group
resource "aws_security_group" "app" {
  name_prefix = "${var.app_name}-sg"
  vpc_id      = aws_vpc.main.id

  # HTTP
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # HTTPS
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # SSH
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = var.allowed_ssh_ips
  }

  # Egress - Allow all outbound traffic
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.app_name}-sg"
  }
}

# IAM Role for EC2
resource "aws_iam_role" "ec2_role" {
  name_prefix = "${var.app_name}-ec2-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })
}

# IAM Policy for ECR access
resource "aws_iam_role_policy" "ecr_access" {
  name_prefix = "${var.app_name}-ecr-policy"
  role        = aws_iam_role.ec2_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "ecr:GetAuthorizationToken",
          "ecr:GetDownloadUrlForLayer",
          "ecr:BatchGetImage",
          "ecr:BatchCheckLayerAvailability"
        ]
        Resource = "*"
      }
    ]
  })
}

# IAM Instance Profile
resource "aws_iam_instance_profile" "ec2_profile" {
  name_prefix = "${var.app_name}-ec2-profile"
  role        = aws_iam_role.ec2_role.name
}

# Get latest Amazon Linux 2 AMI
data "aws_ami" "amazon_linux_2" {
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

  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }
}

# User data script
locals {
  user_data = base64encode(templatefile("${path.module}/user_data.sh", {
    ecr_registry = "${data.aws_caller_identity.current.account_id}.dkr.ecr.${var.aws_region}.amazonaws.com"
    app_name     = var.app_name
    aws_region   = var.aws_region
  }))
}

# EC2 Instance
resource "aws_instance" "app" {
  count                    = var.instance_count
  ami                      = data.aws_ami.amazon_linux_2.id
  instance_type            = var.instance_type
  key_name                 = var.key_pair_name
  subnet_id                = aws_subnet.public.id
  vpc_security_group_ids   = [aws_security_group.app.id]
  iam_instance_profile     = aws_iam_instance_profile.ec2_profile.name
  associate_public_ip_address = true

  user_data = local.user_data

  monitoring = true

  root_block_device {
    volume_type           = "gp3"
    volume_size           = 20
    delete_on_termination = true
    encrypted             = true
  }

  tags = {
    Name = "${var.app_name}-instance-${count.index + 1}"
  }

  depends_on = [aws_internet_gateway.main]
}

# Elastic IP for static IP
resource "aws_eip" "app" {
  count    = var.instance_count
  instance = aws_instance.app[count.index].id
  domain   = "vpc"

  tags = {
    Name = "${var.app_name}-eip-${count.index + 1}"
  }

  depends_on = [aws_internet_gateway.main]
}

# CloudWatch Log Group
resource "aws_cloudwatch_log_group" "app" {
  name_prefix            = "/aws/ec2/${var.app_name}"
  retention_in_days      = 7

  tags = {
    Name = "${var.app_name}-logs"
  }
}

# Data sources
data "aws_availability_zones" "available" {
  state = "available"
}

data "aws_caller_identity" "current" {}
