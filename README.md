# Todo App - Daily To-Do List with History

A modern React application for managing daily tasks with a complete history of all completed/deleted tasks.

## Features

✅ **Daily Task Management**
- Add, complete, and delete tasks
- Clear all completed tasks at once
- Date tracking for each task

📚 **Task History**
- View all deleted tasks organized by date
- Track completed vs. incomplete tasks
- Full task history for reference

💾 **Local Storage**
- Automatic data persistence in browser
- Data survives browser refreshes
- No backend required for basic functionality

🎨 **Modern UI**
- Responsive design for all devices
- Beautiful gradient styling
- Smooth animations and transitions
- Easy-to-use interface

## Project Structure

```
├── src/
│   ├── components/
│   │   ├── TodoForm.js       # Task input form
│   │   ├── TodoList.js       # Task list display
│   │   └── History.js        # Task history view
│   ├── styles/
│   │   ├── TodoForm.css
│   │   ├── TodoList.css
│   │   └── History.css
│   ├── App.js               # Main app component
│   ├── App.css              # App styling
│   └── index.js             # React entry point
├── public/
│   └── index.html           # HTML template
├── Dockerfile               # Docker containerization
├── docker-compose.yml       # Docker Compose config
├── nginx.conf              # Nginx web server config
├── Jenkinsfile             # CI/CD pipeline
├── terraform/              # Infrastructure as Code
│   ├── main.tf             # Terraform main config
│   ├── variables.tf        # Variables
│   ├── networking.tf       # AWS resources
│   ├── outputs.tf          # Terraform outputs
│   ├── user_data.sh        # EC2 initialization script
│   └── terraform.tfvars.example
└── package.json            # Node dependencies
```

## Local Development

### Prerequisites
- Node.js 16+ 
- npm or yarn

### Installation
```bash
npm install
```

### Run Locally
```bash
npm start
```

The app will open at `http://localhost:3000`

### Build for Production
```bash
npm run build
```

## Docker Deployment

### Build Docker Image
```bash
docker build -t todo-app:latest .
```

### Run Docker Container Locally
```bash
docker run -p 80:80 todo-app:latest
```

Access at `http://localhost`

### Using Docker Compose
```bash
docker-compose up
```

## AWS Deployment

### Quick Start
1. Follow [DEPLOYMENT_GUIDE.md](./DEPLOYMENT_GUIDE.md)
2. Set up AWS resources with Terraform
3. Configure Jenkins for CI/CD
4. Deploy to EC2

### Infrastructure
- **Compute:** EC2 instances (t3.micro)
- **Networking:** VPC, Security Groups, Internet Gateway
- **Container Registry:** AWS ECR
- **CI/CD:** Jenkins pipeline
- **Monitoring:** CloudWatch logs

### Access Application
After deployment, access your app at:
```
http://<EC2_PUBLIC_IP>
```

## Available Scripts

```bash
# Start development server
npm start

# Build for production
npm run build

# Run tests
npm test

# Deploy to AWS EC2
# (Automated via Jenkinsfile)
```

## Technologies Used

- **Frontend:** React 18, CSS3
- **Containerization:** Docker, Docker Compose
- **Infrastructure:** Terraform, AWS
- **CI/CD:** Jenkins
- **Web Server:** Nginx
- **Storage:** Browser LocalStorage

## Browser Support

- Chrome/Edge 90+
- Firefox 88+
- Safari 14+
- Mobile browsers (iOS Safari, Chrome Mobile)

## Performance

- Optimized Docker image (~40MB)
- Nginx gzip compression enabled
- CSS/JS caching headers
- Response time: <100ms

## Security Features

- Docker multi-stage builds
- IAM roles for EC2
- Security groups with minimal permissions
- Encrypted EBS volumes
- HTTPS ready (add SSL certificate)
- Security headers in Nginx

## Cost Estimation (AWS)

Using AWS Free Tier:
- t3.micro EC2: Free for 12 months
- ECR: Free for first 500MB
- CloudWatch: Free tier included
- Data Transfer: Minimal cost

**Estimated Monthly Cost:** $0-5 after free tier

## Contributing

1. Fork the repository
2. Create feature branch (`git checkout -b feature/amazing-feature`)
3. Commit changes (`git commit -m 'Add amazing feature'`)
4. Push to branch (`git push origin feature/amazing-feature`)
5. Open Pull Request

## License

MIT License - See LICENSE file for details

## Support & Contact

For issues, questions, or deployment help:
1. Check [DEPLOYMENT_GUIDE.md](./DEPLOYMENT_GUIDE.md) for troubleshooting
2. Review Terraform output for resource information
3. Check CloudWatch logs for runtime errors

## Future Enhancements

- ☐ Backend API integration
- ☐ User authentication
- ☐ Database persistence (PostgreSQL/DynamoDB)
- ☐ Task categories/tags
- ☐ Due dates and reminders
- ☐ Dark mode
- ☐ Export tasks (PDF/CSV)
- ☐ Task statistics and analytics
- ☐ Mobile app (React Native)

---

**Happy task management! 📋✨**
