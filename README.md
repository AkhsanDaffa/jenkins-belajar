# 🚀 Raspberry Pi DevSecOps Pipeline

> **A fully automated, secure, and self-healing CI/CD pipeline running on ARM64 architecture (Raspberry Pi).**

![Jenkins](https://img.shields.io/badge/Jenkins-D24939?style=for-the-badge&logo=jenkins&logoColor=white)
![Docker](https://img.shields.io/badge/Docker-2496ED?style=for-the-badge&logo=docker&logoColor=white)
![Raspberry Pi](https://img.shields.io/badge/Raspberry%20Pi-C51A4A?style=for-the-badge&logo=Raspberry%20Pi&logoColor=white)
![Trivy](https://img.shields.io/badge/Security-Trivy-blue?style=for-the-badge)

## 📋 Project Overview
This project demonstrates a complete **End-to-End DevSecOps Pipeline** built on limited resources (Raspberry Pi). It automates the deployment of a web application while ensuring code quality and security standards are met before production.

The system features **Automated Testing**, **Vulnerability Scanning**, **Zero-Touch Maintenance**, and **Interactive Rollback Capabilities**.

---

## 🏗️ Architecture Workflow

```mermaid
graph TD
    User[Developer] -->|Push Code| Github
    User -->|Build & Push Image| Registry[Local Docker Registry]
    
    subgraph "Raspberry Pi Server (Jenkins)"
        Github -->|Trigger Webhook| Pipeline
        Pipeline -->|1. Quality Control| Test[Bash Script Validations]
        Test -->|2. Security Scan| Trivy[Trivy Vuln Scanner]
        Trivy -->|3. Deploy| Prod[Production Container]
        
        Cron[Weekly Maintenance Job] -->|Clean Garbage| DockerSystem
    end
    
    Pipeline -->|Notify Status| Discord
    Cron -->|Notify Cleanup| Discord

🛠️ Key Features
1. 🛡️ DevSecOps Integration (Trivy)
Security is not an afterthought. Every image is scanned for vulnerabilities (CVEs) before deployment using AquaSec Trivy.

Policy: The pipeline automatically FAILS if CRITICAL or HIGH vulnerabilities are detected.

Optimization: Runs efficiently on ARM64 architecture with cached DB.

2. 🕹️ Parameterized Build & Rollback
Interactive Jenkins menu allowing total control over the environment:

Deploy Latest: Automatically pulls git hash and deploys.

Rollback: Emergency feature to revert to a specific Git Commit Hash if bugs are found in production.

3. 🧹 Automated Self-Healing (Cron)
A dedicated "Janitor" job runs every Sunday at 4:00 AM to prevent storage overflow on the Raspberry Pi.

Action: Prunes unused Docker images, volumes, and build cache.

Result: Maintains system stability and longevity of the SD Card.

4. 🔔 Real-time Monitoring (Discord)
Integrated with Discord Webhooks to provide instant feedback.

Success: Green notification with version ID and Website Link.

Failure: Red alert with error logs (Security breach or Test failure).

🔧 Tech Stack
Component,Technology,Description
Orchestrator,Jenkins,Managing pipelines and workflows
Containerization,Docker,"Hosting Registry, Jenkins, and App"
Security,Trivy,Vulnerability Scanner for Containers
WebServer,Nginx Alpine,Lightweight production server
Notifications,Discord API,Webhook for build status updates
Hardware,Raspberry Pi 4,ARM64 Server Infrastructure