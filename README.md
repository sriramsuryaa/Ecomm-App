# Ecommerce App - DevOps Project

This project demonstrates a complete DevOps pipeline for deploying an Ecommerce web application. It includes CI/CD automation, containerization, infrastructure provisioning, monitoring, and alerting.

## Project Overview

The Ecommerce App is a web-based application containerized using Docker and deployed to AWS EC2 instances. The project implements a robust DevOps workflow with:

- **Multi-environment deployment**: Separate DEV and PROD environments
- **Automated CI/CD**: Jenkins multibranch pipeline triggered on code pushes
- **Containerization**: Docker-based deployment with Nginx
- **Monitoring & Alerting**: Prometheus, Grafana, and Blackbox exporter with SNS notifications
- **Infrastructure**: AWS EC2 instances for hosting

## What Was Accomplished

### 🏗️ **Infrastructure Setup**
- **Created EC2 Instances**: Provisioned AWS EC2 instances (t3.micro with Ubuntu OS) for DEV and PROD environments
- **Instance Configuration**: Set up Docker and Docker Compose on EC2 instances for containerized deployments

### 🚀 **CI/CD Pipeline**
- **Jenkins Multibranch Pipeline**: Implemented automated deployment triggered by code pushes to different branches
  - `main` branch → Production deployment
  - Other branches → Development deployment
- **Jenkinsfile**: Configured pipeline with stages for building, pushing Docker images, and deploying to EC2

### 🐳 **Containerization**
- **Dockerized Application**: Created Dockerfile using Nginx Alpine to serve the static Ecommerce app
- **Docker Compose**: Set up service orchestration for easy deployment management
- **Docker Hub Integration**: Automated pushing of images to repositories (`sriramsuryaa/ecomm-app-dev` and `sriramsuryaa/ecomm-app-prod`)

### 📊 **Monitoring & Alerting**
- **Prometheus Setup**: Configured metrics collection with Blackbox exporter for HTTP endpoint monitoring
- **Grafana Dashboards**: Created custom dashboards for DEV and PROD environments (`ECOMMERCE-APP-DEV.json`, `ECOMMERCE-APP-PROD.json`)
- **Blackbox Exporter**: Implemented HTTP status monitoring (checking for 200 status codes)
- **SNS Alerting**: Configured notifications via AWS SNS when application status is not 200

### 📁 **Project Structure**
- **Build Scripts**: `build.sh` for Docker image creation and push
- **Deployment Scripts**: `deploy.sh` for pulling and running containers on EC2
- **Configuration Files**: Docker Compose, Prometheus config, and monitoring stack setup
- **Documentation**: Comprehensive README.md with setup instructions and architecture overview

### 🔄 **Automation Workflow**
1. Code push to Git branch
2. Jenkins pipeline triggers
3. Docker image build and push
4. SSH deployment to appropriate EC2 instance
5. Container update and health monitoring
6. Alerts via SNS if application goes down

## Architecture

```
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   Git Branch    │───▶│   Jenkins CI/CD │───▶│   Docker Build  │
│   (dev/main)    │    │   Multibranch   │    │   & Push        │
└─────────────────┘    └─────────────────┘    └─────────────────┘
                                                        │
                                                        ▼
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   EC2 DEV       │    │   EC2 PROD      │    │   Monitoring    │
│   Instance      │    │   Instance      │    │   Stack         │
│   (Port 80)     │    │   (Port 80)     │    │                 │
└─────────────────┘    └─────────────────┘    └─────────────────┘
       │                        │                        │
       └────────────────────────┼────────────────────────┘
                                ▼
                   ┌─────────────────┐
                   │   Blackbox      │
                   │   Exporter      │
                   └─────────────────┘
                            │
                   ┌─────────────────┐
                   │   Prometheus    │
                   └─────────────────┘
                            │
                   ┌─────────────────┐
                   │   Grafana       │
                   │   (Dashboards)  │
                   └─────────────────┘
                            │
                   ┌─────────────────┐
                   │   SNS Alerting  │
                   │   (Status ≠ 200)│
                   └─────────────────┘
```

## Prerequisites

- AWS Account with EC2 access
- Jenkins server with Docker and SSH plugins
- Docker Hub account
- Git repository (GitHub/GitLab)
- AWS CLI configured

## Infrastructure Setup

### 1. Create EC2 Instances

Create two EC2 instances (one for DEV, one for PROD) using AWS Console or CLI:

**AWS Console Method:**
1. Go to EC2 Dashboard → Launch Instance
2. Choose Ubuntu Server (latest LTS)
3. Instance Type: t3.micro
4. Configure security groups (ports 22, 80)
5. Launch with key pair

**AWS CLI Method:**
```bash
# DEV Environment
aws ec2 run-instances \
  --image-id ami-0abcdef1234567890 \
  --count 1 \
  --instance-type t3.micro \
  --key-name your-key-pair \
  --security-group-ids sg-12345678 \
  --tag-specifications 'ResourceType=instance,Tags=[{Key=Name,Value=Ecomm-App-DEV}]'

# PROD Environment
aws ec2 run-instances \
  --image-id ami-0abcdef1234567890 \
  --count 1 \
  --instance-type t3.micro \
  --key-name your-key-pair \
  --security-group-ids sg-12345678 \
  --tag-specifications 'ResourceType=instance,Tags=[{Key=Name,Value=Ecomm-App-PROD}]'
```

**Security Group Requirements:**
- Allow inbound traffic on port 80 (HTTP)
- Allow inbound traffic on port 22 (SSH) from Jenkins server & My public IP
- Allow outbound traffic to Docker Hub and other required services

### 2. Configure EC2 Instances

On each EC2 instance, install Docker and Docker Compose:

```bash
# Update system
sudo apt update && sudo apt upgrade -y

# Install Docker
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh
sudo usermod -aG docker ubuntu

# Install Docker Compose
sudo curl -L "https://github.com/docker/compose/releases/download/v2.24.0/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose

# Create deployment directory
sudo mkdir -p /home/ubuntu/deploy
sudo chown ubuntu:ubuntu /home/ubuntu/deploy
```

Copy the `docker-compose.yml` and `deploy.sh` files to `/home/ubuntu/deploy/` on each instance.

## CI/CD Pipeline

### Jenkins Setup

1. **Create Multibranch Pipeline Job:**
   - Job Name: `ecomm-app-multibranch`
   - Branch Sources: Git (point to your repository)
   - Build Configuration: `Jenkinsfile` from SCM

2. **Configure Credentials:**
   - `dockerhub-credentials`: Docker Hub username/password
   - `ecomm-server`: SSH private key for EC2 access

3. **Environment Variables:**
   - `EC_APP_DEV`: DEV EC2 instance public IP/hostname
   - `EC_APP_PROD`: PROD EC2 instance public IP/hostname

### Pipeline Flow

The Jenkins pipeline:
1. **Set Variables**: Determines target environment based on branch (`main` → PROD, others → DEV)
2. **Build & Push**: Builds Docker image and pushes to Docker Hub
3. **Deploy to EC2**: SSH into target EC2 instance and runs deployment script

## Application Deployment

### Docker Configuration

The application is containerized using:
- **Base Image**: `nginx:alpine`
- **Port**: 80
- **Build Context**: Static files from `build/` directory

### Environment-Specific Images

- **DEV**: `sriramsuryaa/ecomm-app-dev:latest`
- **PROD**: `sriramsuryaa/ecomm-app-prod:latest`

## Monitoring & Alerting

### Monitoring Stack

The monitoring stack includes:

1. **Blackbox Exporter**: Probes HTTP endpoints for availability
2. **Prometheus**: Time-series database for metrics collection
3. **Grafana**: Visualization dashboard with custom panels

### Setup Monitoring

1. **On Monitoring Server:**
   ```bash
   cd monitoring/
   docker-compose up -d
   ```

2. **Access Points:**
   - Grafana: http://monitoring-server:3000 (admin/admin)
   - Prometheus: http://monitoring-server:9090

### Grafana Dashboards

Pre-configured dashboards for DEV and PROD environments:
- `ECOMMERCE-APP-DEV.json`
- `ECOMMERCE-APP-PROD.json`

Import these dashboards into Grafana for monitoring application health.

### Alerting Configuration

**SNS Alerting Setup:**

1. Create SNS Topic in AWS Console
2. Configure Grafana Alerting:
   - Notification Channel: SNS
   - Topic ARN: Your SNS topic
3. Alert Rule: Trigger when HTTP status ≠ 200

## Usage

### Deploying Changes

1. **DEV Deployment**: Push code to any branch except `main`
2. **PROD Deployment**: Push code to `main` branch
3. Jenkins will automatically build and deploy based on branch

### Monitoring Application

- Check Grafana dashboards for real-time metrics
- Receive SNS alerts for application downtime
- View Prometheus metrics at http://monitoring-server:9090

### Scaling

- Horizontal scaling: Add more EC2 instances and update load balancer
- Vertical scaling: Upgrade EC2 instance types
- Monitoring scaling: Adjust Prometheus scrape intervals

## Troubleshooting

### Common Issues

1. **Deployment Failures:**
   - Check Jenkins logs for build errors
   - Verify SSH connectivity to EC2 instances
   - Ensure Docker Hub credentials are valid

2. **Application Not Accessible:**
   - Check EC2 security groups
   - Verify Docker containers are running: `docker-compose ps`
   - Check application logs: `docker-compose logs`

3. **Monitoring Issues:**
   - Verify Prometheus targets are up
   - Check Blackbox exporter configuration
   - Ensure Grafana can connect to Prometheus

### Logs

- **Jenkins Logs**: Available in Jenkins UI
- **Application Logs**: `docker-compose logs app`
- **Monitoring Logs**: `docker-compose logs` in monitoring directory

## Security Considerations

- Use IAM roles with minimal required permissions
- Rotate SSH keys and Docker Hub credentials regularly
- Implement network segmentation between environments
- Enable AWS CloudTrail for audit logging
- Use encrypted communication (HTTPS) in production

