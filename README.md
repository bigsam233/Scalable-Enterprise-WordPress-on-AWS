# Scalable Enterprise WordPress on AWS

## 📌 Overview

This project demonstrates the design and deployment of a **highly available, scalable, and production-grade WordPress architecture** on AWS.

Unlike traditional single-server WordPress setups, this implementation adopts a **decoupled, multi-tier architecture** that separates compute, storage, and database layers. This improves:

- Availability (Multi-AZ design)
- Scalability (Auto Scaling)
- Performance (CloudFront CDN + EFS)
- Security (Private subnets, controlled access)

This project reflects how real-world cloud systems are built and managed.

---

## 🏗️ Architecture
<img width="1536" height="1024" alt="Scalable Enterprise WordPress on AWS Architecture by Samuel Tettey-fio" src="https://github.com/user-attachments/assets/e08f29e3-452c-445d-9114-299e2b84f867" />


### Request Flow

1. User sends request  
2. Amazon CloudFront serves cached content or forwards request  
3. Application Load Balancer (ALB) distributes traffic  
4. EC2 instances (Auto Scaling Group) process requests  
5. EC2 retrieves:
   - Media files from Amazon EFS  
   - Data from Amazon RDS  
6. Response is returned to the user via CloudFront  

---

### Key Components

- **CloudFront (CDN):** Global content delivery and caching  
- **Application Load Balancer (ALB):** Traffic distribution  
- **Auto Scaling Group (ASG):** Scaling and self-healing  
- **EC2 Instances:** WordPress application servers  
- **Amazon EFS:** Shared file storage (`wp-content`)  
- **Amazon RDS (MySQL):** Managed database  
- **VPC:** Isolated network with public, private, and data subnets  
- **NAT Gateway:** Internet access for private instances  

---

## 🧰 Tech Stack

| Category        | Technology |
|----------------|-----------|
| Cloud Provider | AWS |
| Compute        | EC2 (Amazon Linux 2023) |
| Scaling        | Auto Scaling Group |
| Load Balancing | Application Load Balancer |
| Storage        | Amazon EFS |
| Database       | Amazon RDS (MySQL) |
| CDN            | Amazon CloudFront |
| Networking     | VPC, Subnets, IGW, NAT Gateway |
| Web Server     | Apache |
| Backend        | PHP |
| CMS            | WordPress |

---

## ⚙️ Implementation (Step-by-Step)

### 🔹 Phase 1: VPC & Networking

- Created a custom VPC (`10.0.0.0/16`)
- Configured:
  - 2 Public Subnets (for ALB)
  - 2 Private Subnets (for EC2)
  - 2 Data Subnets (for RDS & EFS)
- Attached Internet Gateway (IGW)
- Created NAT Gateway for private subnet internet access
- Configured route tables:
  - Public → IGW
  - Private → NAT

---

### 🔹 Phase 2: Data Layer (RDS & EFS)

#### Amazon RDS
- Engine: MySQL
- Deployed in private/data subnets
- Disabled public access
- Configured security group to allow access only from EC2

#### Amazon EFS
- Created regional file system
- Mounted across EC2 instances
- Used for:
  /var/www/html/wp-content

---

### 🔹 Phase 3: Compute Layer

#### EC2 Setup
- Launched Amazon Linux 2023 instance
- Installed Apache, PHP, and WordPress
- Configured:
  - wp-config.php with RDS endpoint
  - Mounted EFS for shared uploads

#### AMI Creation
- Created a Golden AMI after configuration

#### Launch Template
- Created using the AMI

#### Auto Scaling Group
- Minimum instances: 2
- Multi-AZ deployment
- Health checks enabled

---

### 🔹 Phase 4: Load Balancing & Security

#### Application Load Balancer
- Deployed in public subnets
- Listener: HTTP (Port 80)
- Connected to target group

#### Security Groups
- ALB SG → Allow HTTP/HTTPS from internet
- EC2 SG → Allow HTTP from ALB only
- RDS SG → Allow MySQL from EC2 only

---

### 🔹 Phase 5: Performance Optimization (CloudFront)

- Created CloudFront distribution
- Set ALB as origin
- Enabled caching for static assets
- Updated WordPress to use CloudFront domain

---

## 🧪 Challenges & Solutions

### ❌ Error: Database Connection Failed
**Fix:**
- Verified RDS endpoint
- Updated security group rules

---

### ❌ EFS Permission Error
**Fix:**
```bash
sudo chown -R apache:apache /var/www/html/wp-content
