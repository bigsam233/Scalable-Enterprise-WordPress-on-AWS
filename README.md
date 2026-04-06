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
##### *Creation of VPC*
<img width="1704" height="870" alt="Creation of VPC" src="https://github.com/user-attachments/assets/aed79b05-c58f-4aea-b352-3198d763a81e" />

---

### 🔹 Phase 2: Data Layer (RDS & EFS)

#### Amazon RDS
- Engine: MySQL
- Deployed in private/data subnets
- Disabled public access
- Configured security group to allow access only from EC2

##### *Creation of RDS*
<img width="1703" height="981" alt="Creation of EDS 1" src="https://github.com/user-attachments/assets/9f986835-d739-4b08-8499-20d455378e37" />

##### *Security group for the database*
<img width="1473" height="567" alt="Security group for the database" src="https://github.com/user-attachments/assets/58e3de1d-b0bd-495e-a170-93e596533f54" />

#### Amazon EFS
- Created regional file system
- Mounted across EC2 instances
- Used for:
  /var/www/html/wp-content

##### *Creation of EFS* 
<img width="1687" height="972" alt="Creation of EFS" src="https://github.com/user-attachments/assets/4ca9872f-0b24-4475-bf2a-0267224d2b27" />

---

### 🔹 Phase 3: Compute Layer

#### EC2 Setup
- Launched Amazon Linux 2023 instance
- Installed Apache, PHP, and WordPress
- Configured:
  - wp-config.php with RDS endpoint
  - Mounted EFS for shared uploads

##### *Launch of EC2 instance 1* 
<img width="1668" height="958" alt="Launch of EC2 instance 1" src="https://github.com/user-attachments/assets/e8c851e5-3b2d-4c71-8ab6-2cac6d1c1812" />

##### *Launch of EC2 instance 2* 
<img width="1668" height="958" alt="Launch of EC2 instance 2" src="https://github.com/user-attachments/assets/384ebfcb-a886-4427-b8c6-2d76f04212a9" />

##### *SSH into Ec2 instance and installing Apache* 
<img width="830" height="550" alt="SSH into Ec2 instance and installing Apache" src="https://github.com/user-attachments/assets/3dac0b1f-0ca8-449d-8c4c-7b2307e8664c" />

##### *Mounting of EFS* 
<img width="830" height="178" alt="Mounting of EFS" src="https://github.com/user-attachments/assets/20298283-6ce0-43d9-aff9-4af44156e432" />


#### AMI Creation
- Created a Golden AMI after configuration

##### *Creation of AMI 1* 
<img width="1709" height="1067" alt="Creation of AMI 1" src="https://github.com/user-attachments/assets/00ace357-2e79-427c-80fc-ce3f517c1d30" />

##### *Creation of AMI 2* 
<img width="1709" height="1067" alt="Creation of AMI 2" src="https://github.com/user-attachments/assets/7005c1e5-6b2f-44bb-b8fe-efa51da2c638" />


#### Launch Template
- Created using the AMI

#### Auto Scaling Group
- Minimum instances: 2
- Multi-AZ deployment
- Health checks enabled

##### *Creation of Autoscaling*
<img width="1677" height="1012" alt="Creation of Autoscaling" src="https://github.com/user-attachments/assets/77d3e79b-09dc-451b-aede-aba643983d56" />

---

### 🔹 Phase 4: Load Balancing & Security

#### Application Load Balancer
- Deployed in public subnets
- Listener: HTTP (Port 80)
- Connected to the target group

#### Security Groups
- ALB SG → Allow HTTP/HTTPS from the internet
- EC2 SG → Allow HTTP from ALB only
- RDS SG → Allow MySQL from EC2 only

##### *Security group for EC2*
<img width="1473" height="567" alt="Security group for EC2" src="https://github.com/user-attachments/assets/d3bba77a-07e1-40cd-81cd-c7fbb79eedd5" />

##### *Security group for the database*
<img width="1473" height="567" alt="Security group for the database" src="https://github.com/user-attachments/assets/15776843-768a-4c5c-a9bf-4526557311ab" />

##### *Security Group for EFS*
<img width="1473" height="567" alt="Security Group for EFS" src="https://github.com/user-attachments/assets/7e71271a-5f7e-41e3-a860-1fee896d75ae" />

---

### 🔹 Phase 5: Performance Optimisation (CloudFront)

- Created CloudFront distribution
- Set ALB as origin
- Enabled caching for static assets
- Updated WordPress to use CloudFront domain

##### *Creation of Cloudfront distribution*
<img width="1701" height="1037" alt="Creation of Cloudfront dsitribution" src="https://github.com/user-attachments/assets/cd7e20da-1bd1-4e8f-8ed7-b2da58f9c7e1" />

---

## ✅ Working WordPress
##### *EC2 public IP showing WordPress Installation*
<img width="1709" height="1067" alt="EC2 public ip showing WordPress Installation" src="https://github.com/user-attachments/assets/254ad0c0-a006-4b8c-8992-6ca75c233d91" />

##### *WordPress successfully installed on EC2*
<img width="1709" height="1067" alt="WordPress successfully installed on EC2" src="https://github.com/user-attachments/assets/99149069-fef8-486e-8e65-82cb2f67c37c" />



## 🧪 Challenges & Solutions

### ❌ Error: Database Connection Failed
**Fix:**
- Verified RDS endpoint
- Updated security group rules

---

### ❌ EFS Permission Error
**Fix:**
sudo chown -R apache:apache /var/www/html/wp-content

### ❌ CloudFront 504 Gateway Timeout
**Fix:**
- Set origin protocol to HTTP
- Updated security groups
- Cleared cache using invalidation

## 📬 Contact  
If you’re a recruiter or hiring manager looking for a Cloud/DevOps Engineer, feel free to connect via email at samuel.tfio@gmail.com

## 🔗 Links

[![linkedin](https://img.shields.io/badge/linkedin-0A66C2?style=for-the-badge&logo=linkedin&logoColor=white)](https://www.linkedin.com/in/samuel-tettey-fio/)


## Authors

- [@bigsam233](https://www.github.com/bigsam233)
