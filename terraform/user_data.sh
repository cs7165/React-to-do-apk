#!/bin/bash
set -e

# Update system
yum update -y

# Install Docker
amazon-linux-extras install docker -y
systemctl start docker
systemctl enable docker

# Add ec2-user to docker group
usermod -a -G docker ec2-user

# Install Docker Compose
curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
chmod +x /usr/local/bin/docker-compose

# Install AWS CLI
yum install -y aws-cli

# Create app directory
mkdir -p /opt/todo-app
cd /opt/todo-app

# Login to ECR
aws ecr get-login-password --region ${aws_region} | docker login --username AWS --password-stdin ${ecr_registry}

# Pull and run the application
docker run -d \
  --name ${app_name} \
  -p 80:80 \
  -p 443:443 \
  --restart always \
  --log-driver awslogs \
  --log-opt awslogs-group=/aws/ec2/${app_name} \
  --log-opt awslogs-region=${aws_region} \
  ${ecr_registry}/${app_name}:latest

# Wait for container to be healthy
sleep 10

# Log startup completion
echo "TODO App deployment completed at $(date)" >> /var/log/user-data.log
