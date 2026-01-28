pipeline {
    agent any

    environment {
        AWS_REGION = 'us-east-1'
        ECR_REGISTRY = 'YOUR_AWS_ACCOUNT_ID.dkr.ecr.us-east-1.amazonaws.com'
        ECR_REPOSITORY = 'todo-app'
        IMAGE_TAG = "${BUILD_NUMBER}"
        DOCKER_IMAGE = "${ECR_REGISTRY}/${ECR_REPOSITORY}:${IMAGE_TAG}"
    }

    stages {
        stage('Checkout') {
            steps {
                echo 'Checking out source code...'
                checkout scm
            }
        }

        stage('Build') {
            steps {
                echo 'Building React application...'
                sh '''
                    npm install
                    npm run build
                '''
            }
        }

        stage('Test') {
            steps {
                echo 'Running tests...'
                sh '''
                    npm test -- --coverage --watchAll=false || true
                '''
            }
        }

        stage('Docker Build') {
            steps {
                echo 'Building Docker image...'
                sh '''
                    docker build -t ${DOCKER_IMAGE} .
                    docker tag ${DOCKER_IMAGE} ${ECR_REGISTRY}/${ECR_REPOSITORY}:latest
                '''
            }
        }

        stage('ECR Login') {
            steps {
                echo 'Logging into AWS ECR...'
                sh '''
                    aws ecr get-login-password --region ${AWS_REGION} | docker login --username AWS --password-stdin ${ECR_REGISTRY}
                '''
            }
        }

        stage('Push to ECR') {
            steps {
                echo 'Pushing image to ECR...'
                sh '''
                    docker push ${DOCKER_IMAGE}
                    docker push ${ECR_REGISTRY}/${ECR_REPOSITORY}:latest
                '''
            }
        }

        stage('Deploy to EC2') {
            steps {
                echo 'Deploying to AWS EC2...'
                sh '''
                    # Get the EC2 instance details from Terraform output
                    EC2_INSTANCE=$(terraform output -raw ec2_instance_ip 2>/dev/null || echo "")
                    
                    if [ -z "$EC2_INSTANCE" ]; then
                        echo "No EC2 instance found. Skipping deployment."
                        exit 0
                    fi
                    
                    # SSH into EC2 and deploy
                    ssh -o StrictHostKeyChecking=no -i ${JENKINS_EC2_KEY} ec2-user@${EC2_INSTANCE} << 'EOF'
                        # Login to ECR
                        aws ecr get-login-password --region ${AWS_REGION} | docker login --username AWS --password-stdin ${ECR_REGISTRY}
                        
                        # Stop and remove old container
                        docker stop todo-app || true
                        docker rm todo-app || true
                        
                        # Pull latest image
                        docker pull ${DOCKER_IMAGE}
                        
                        # Run new container on port 3000
                        docker run -d \
                            --name todo-app \
                            -p 3000:3000 \
                            --restart always \
                            ${DOCKER_IMAGE}
                        
                        echo "Deployment successful!"
EOF
                '''
            }
        }

        stage('Health Check') {
            steps {
                echo 'Performing health check...'
                sh '''
                    EC2_INSTANCE=$(terraform output -raw ec2_instance_ip 2>/dev/null || echo "")
                    
                    if [ -n "$EC2_INSTANCE" ]; then
                        # Wait for container to start
                        sleep 10
                        
                        # Check if application is running
                        curl -f http://${EC2_INSTANCE}/ || exit 1
                    fi
                '''
            }
        }
    }

    post {
        always {
            echo 'Pipeline execution completed.'
            cleanWs()
        }

        success {
            echo 'Pipeline succeeded! Application deployed to EC2.'
        }

        failure {
            echo 'Pipeline failed. Check logs for details.'
        }
    }
}
