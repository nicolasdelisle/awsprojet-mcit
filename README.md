# awsprojet-mcit

## 📌 Project Overview
This project demonstrates the deployment of a **two-tier AWS architecture** to host a standard web application with a database, using **Terraform** for Infrastructure as Code (IaC) and **Terraform Cloud** for CI/CD automation.

graph from web site not my original:
![Project Graph](images/graph.webp)

---

## 🎯 Objectives
- Host a lightweight web application with a MySQL database  
- Use AWS best practices for security and scalability  
- Deploy infrastructure using Terraform for repeatability and automation  

---

## 🏗 Architecture
The infrastructure includes:  
- **Custom VPC**
  - 2 Public Subnets for the **Web Server Tier**  
  - 2 Private Subnets for the **RDS Tier**  
- **Appropriate Route Tables** for internet and internal communication  
- **2 EC2 Instances** (Apache or NGINX) in the public subnets  
- **1 RDS MySQL Instance** (micro) in the private subnets  
- **Security Groups** for controlled access  
- **Application Load Balancer** for traffic distribution  
- Automated deployment via **Terraform Cloud**  

---

## 🔧 Design Decisions

1. **Region Selection**  
   AWS **us-east-1** was chosen for low latency to the client location.  

2. **VPC Isolation**  
   A dedicated VPC ensures network separation from other environments.  

3. **EC2 Configuration**  
   - Instance Type: `t2.micro` – suitable for a lightweight application  
   - Public subnets with internet access for serving content  

4. **Load Balancer**  
   Distributes incoming traffic between the two web servers for high availability.  

5. **RDS Database**  
   - MySQL deployed in **private subnets** for security  
   - No internet access – accessible only by web server tier  

6. **Security Groups**  
   - **Web Server SG:** Allow SSH (22) and HTTP (80)  
   - **RDS SG:** Allow MySQL (3306) only from the Web Server SG  
   - Production note: Use HTTPS (443) instead of HTTP for secure communication  

7. **Terraform Advantages**  
   - Easy scaling and updates  
   - Reusable code for similar future projects  

---

## 📋 Prerequisites 
- An **AWS account** with appropriate IAM permissions  
- **Terraform CLI**   
- AWS CLI configured locally:  
  ```bash
  aws configure
