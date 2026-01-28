# AWS EC2 Deployment Guide for Todo App

## Prerequisites

1. **AWS Account** - Active AWS account with appropriate permissions
2. **Terraform** - Install Terraform (v1.0+)
3. **AWS CLI** - Install and configure AWS CLI
4. **Docker** - Docker installed locally for building images
5. **Jenkins** - Jenkins server configured for CI/CD
6. **SSH Key Pair** - EC2 key pair for SSH access

## Step 1: Prepare AWS Environment

### Create S3 Bucket for Terraform State
```bash
aws s3api create-bucket --bucket todo-app-terraform-state --region us-east-1
aws s3api put-bucket-versioning \
  --bucket todo-app-terraform-state \
  --versioning-configuration Status=Enabled
aws s3api put-bucket-encryption \
  --bucket todo-app-terraform-state \
  --server-side-encryption-configuration '{
    "Rules": [{"ApplyServerSideEncryptionByDefault": {"SSEAlgorithm": "AES256"}}]
  }'
```

### Create DynamoDB Table for Terraform Locks
```bash
aws dynamodb create-table \
  --table-name terraform-locks \
  --attribute-definitions AttributeName=LockID,AttributeType=S \
  --key-schema AttributeName=LockID,KeyType=HASH \
  --billing-mode PAY_PER_REQUEST
```

### Create EC2 Key Pair
```bash
aws ec2 create-key-pair --key-name todo-app-key --region us-east-1 --query 'KeyMaterial' --output text > todo-app-key.pem
chmod 400 todo-app-key.pem
```

### Create ECR Repository
```bash
aws ecr create-repository \
  --repository-name todo-app \
  --region us-east-1 \
  --image-scan-on-push
```

## Step 2: Build and Push Docker Image

```bash
# Navigate to project root
cd d:\AWS\To-do-apk

# Build React app
npm install
npm run build

# Login to ECR
aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin YOUR_AWS_ACCOUNT_ID.dkr.ecr.us-east-1.amazonaws.com

# Build Docker image
docker build -t todo-app:latest .

# Tag image for ECR
docker tag todo-app:latest YOUR_AWS_ACCOUNT_ID.dkr.ecr.us-east-1.amazonaws.com/todo-app:latest

# Push to ECR
docker push YOUR_AWS_ACCOUNT_ID.dkr.ecr.us-east-1.amazonaws.com/todo-app:latest
```

## Step 3: Deploy with Terraform

### Initialize Terraform
```bash
cd terraform
terraform init
```

### Create terraform.tfvars
```bash
cp terraform.tfvars.example terraform.tfvars

# Edit terraform.tfvars with your values:
# - key_pair_name: Your EC2 key pair name
# - aws_region: Your target AWS region
# - allowed_ssh_ips: Restrict SSH access to your IP
```

### Plan and Apply
```bash
# Review changes
terraform plan

# Apply infrastructure
terraform apply

# Get outputs
terraform output
```

## Step 4: Configure Jenkins Pipeline

### Jenkins Setup Steps

1. **Install Required Plugins:**
   - AWS Credentials
   - Docker Pipeline
   - Terraform
   - SSH Agent

2. **Add Credentials to Jenkins:**
   - AWS Access Key ID and Secret
   - EC2 Key Pair PEM file
   - GitHub repository credentials (if using)

3. **Create New Pipeline Job:**
   - Job name: `todo-app-deploy`
   - Pipeline script from SCM (Git)
   - Repository URL: Your git repository
   - Branch: `main` or `master`

4. **Configure Pipeline:**
   - Set credentials for AWS and GitHub
   - Set environment variables in Jenkins:
     - `AWS_REGION`: us-east-1
     - `AWS_ACCOUNT_ID`: Your AWS account ID

## Step 5: Monitor and Manage

### Check Application Status
```bash
# SSH into EC2 instance
ssh -i todo-app-key.pem ec2-user@<PUBLIC_IP>

# Check running containers
docker ps

# View container logs
docker logs todo-app

# Check application health
curl http://<PUBLIC_IP>
```

### View CloudWatch Logs
```bash
aws logs tail /aws/ec2/todo-app --follow --region us-east-1
```

### Scale Infrastructure
Edit `terraform/terraform.tfvars` and change `instance_count`:
```bash
instance_count = 2  # or desired number
terraform apply
```

## Step 6: SSL/TLS Certificate (Optional)

For production, use AWS Certificate Manager (ACM):

```bash
# Request certificate
aws acm request-certificate \
  --domain-name example.com \
  --validation-method DNS \
  --region us-east-1
```

Then configure nginx.conf with SSL certificates.

## Troubleshooting

### Container won't start
```bash
docker logs todo-app
docker inspect todo-app
```

### Cannot SSH to instance
- Check security group allows port 22
- Verify key pair permissions: `chmod 400 todo-app-key.pem`
- Confirm key pair name matches

### Terraform state locked
```bash
# Release lock manually
aws dynamodb delete-item \
  --table-name terraform-locks \
  --key "{\"LockID\": {\"S\": \"<lock-id>\"}}"
```

### ECR image not found
- Verify image was pushed: `aws ecr describe-images --repository-name todo-app`
- Check ECR login: `aws ecr get-login-password --region us-east-1`

## Cleanup

To destroy all infrastructure:

```bash
# Destroy Terraform resources
terraform destroy

# Delete ECR repository
aws ecr delete-repository --repository-name todo-app --force

# Delete S3 bucket
aws s3 rm s3://todo-app-terraform-state --recursive
aws s3api delete-bucket --bucket todo-app-terraform-state
```

## Security Best Practices

1. **Restrict SSH access** - Update `allowed_ssh_ips` in variables
2. **Use IAM roles** - Leverage EC2 IAM roles for AWS access
3. **Enable encryption** - S3, EBS, and database encryption enabled
4. **CloudWatch monitoring** - Logs are sent to CloudWatch
5. **Regular updates** - Keep Docker images and dependencies updated
6. **Secret management** - Use AWS Secrets Manager for sensitive data

## Cost Optimization

- Use `t3.micro` for free tier (12 months)
- Enable auto-shutdown for non-production
- Use spot instances for cost savings
- Monitor with AWS Cost Explorer

## Additional Resources

- [Terraform AWS Provider Docs](https://registry.terraform.io/providers/hashicorp/aws/latest/docs)
- [AWS EC2 Documentation](https://docs.aws.amazon.com/ec2/)
- [Docker Best Practices](https://docs.docker.com/develop/dev-best-practices/)
- [Jenkins Documentation](https://www.jenkins.io/doc/)
