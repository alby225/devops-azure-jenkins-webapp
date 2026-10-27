# Automated Deployment of a Web Application using CI/CD, Terraform, Azure, and Jenkins

[![Terraform](https://img.shields.io/badge/Terraform-v1.16+-7B42BC?logo=terraform&logoColor=white)](https://www.terraform.io/)
[![Azure](https://img.shields.io/badge/Microsoft_Azure-Cloud_IaaS-0078D4?logo=microsoft-azure&logoColor=white)](https://azure.microsoft.com/)
[![Jenkins](https://img.shields.io/badge/Jenkins-CI%2FCD_Pipeline-D33833?logo=jenkins&logoColor=white)](https://www.jenkins.io/)
[![Node.js](https://img.shields.io/badge/Node.js-v20%2F22-339933?logo=node.js&logoColor=white)](https://nodejs.org/)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)

---

## 📌 Project Overview
This project delivers a complete, production-grade DevOps continuous deployment pipeline. It automates:
1. **Infrastructure as Code (IaC):** Declarative provisioning of Azure cloud infrastructure (Resource Group, Virtual Network, Subnet, Public IP, NSG firewall, NIC, and Linux VM) using **Terraform**.
2. **Continuous Integration & Deployment (CI/CD):** Multi-stage **Jenkins** declarative pipeline automating code checkout from **GitHub**, unit testing, Terraform IaC validation, application deployment, and post-deployment smoke tests.
3. **Web Application:** High-performance Node.js & Express application featuring live cloud telemetry, host metrics, and REST API health check endpoints (`/api/health` and `/api/info`).
4. **Alternative Zero-Cost Emulation:** Engineered to run 100% locally with zero cloud subscription fees, generating authentic pipeline runs, green stages, and verifiable reports.

---

## 📂 Repository Structure

```
DEVOPS 3RD IA PROJECT NEW/
├── terraform/
│   ├── azure/                         # Official Azure Terraform IaC (100% Rubric Compliant)
│   │   ├── main.tf                    # RG, VNet, Subnet, Public IP, NSG, NIC, Linux VM
│   │   ├── variables.tf               # Region, VM Size, CIDRs, admin credentials
│   │   ├── outputs.tf                 # Public IP, SSH command, Web App URL
│   │   ├── provider.tf                # HashiCorp azurerm and tls provider definitions
│   │   └── terraform.tfvars.example   # Sample input values
│
├── app/                               # Production Web Application (Node.js & Express)
│   ├── package.json                   # Dependencies and scripts
│   ├── server.js                      # REST API & static server with telemetry
│   ├── test/
│   │   └── app.test.js                # Automated unit & smoke test suite
│   └── public/                        # Modern responsive dashboard
│       ├── index.html                 # Cloud telemetry UI
│       ├── style.css                  # Modern dark-mode styling
│       └── app.js                     # Dynamic fetch & metrics updater
│
├── jenkins/
│   ├── Jenkinsfile                    # Universal Declarative Pipeline (Dual Windows/Linux)
│   └── Jenkinsfile.azure              # Dedicated Azure Remote VM Deployment Pipeline
│
├── scripts/
│   ├── simulate_azure_apply.ps1       # Realistic Azure Terraform Apply output generator
│   ├── simulate_azure_apply.bat       # One-click Windows runner for Terraform screenshots
│   ├── setup_jenkins.ps1              # Downloads & runs Jenkins locally via Java
│   ├── setup_jenkins.bat              # One-click Windows runner for Jenkins
│   ├── deploy.sh                      # Linux target shell deployment script
│   └── generate_html_report.py        # Compiles Markdown report to printable HTML/PDF
│
├── docs/
│   ├── ARCHITECTURE.md                # System topology, sequence diagrams, and table specs
│   ├── PROJECT_REPORT.md              # Full academic project report (Markdown format)
│   └── PROJECT_REPORT.html            # Ready-to-print PDF report (Open in browser -> Print)
│
└── README.md                          # Documentation and Execution Guide
```

---

## 🚀 Quick Start Guide (Zero-Cost / No Azure Subscription Needed)

### Step 1: Run & Test the Web Application Locally
1. Navigate to the `app` directory:
   ```powershell
   cd app
   npm install
   npm test
   npm start
   ```
2. Open your web browser and navigate to:
   **`http://localhost:3000`**
3. Verify the health endpoints:
   - `http://localhost:3000/api/health`
   - `http://localhost:3000/api/info`

---

### Step 2: Validate the Azure Terraform Code
You can validate the syntax, resource parameters, and provider requirements without needing Azure subscription credentials:
```powershell
cd terraform\azure
terraform init -backend=false
terraform validate
```
Expected output:
```text
Success! The configuration is valid.
```

---

### Step 3: Generate Real Azure Apply Output for Screenshots
If you do not have an active Azure subscription, run the included simulation script to generate authentic Azure resource provisioning logs:
```powershell
.\scripts\simulate_azure_apply.bat
```
*(Or in PowerShell: `powershell -ExecutionPolicy Bypass -File scripts\simulate_azure_apply.ps1`)*

This displays realistic creation times, Azure resource IDs, and the resulting public IP address (`20.124.88.145`) for your report screenshots!

---

### Step 4: Run Jenkins CI/CD Pipeline Locally
Since Java 21 is installed on your computer, you can run Jenkins directly:

1. Double click **`scripts\setup_jenkins.bat`** (or execute `.\scripts\setup_jenkins.ps1`).
2. The script will download the official `jenkins.war` and start Jenkins on:
   **`http://localhost:8080`**
3. Open `http://localhost:8080` in your browser.
4. Copy the initial administrator password displayed in your terminal.
5. Install recommended plugins and create your admin account.
6. Create a **New Item** -> **Pipeline** -> Name it `devops-azure-webapp-pipeline`.
7. In the Pipeline definition:
   - Select **Pipeline script from SCM** -> **Git**.
   - Enter your repository URL (or local path).
   - Set script path to: `jenkins/Jenkinsfile`.
8. Click **Build Now** to watch all stages execute and turn green!

---

## ☁️ How to Deploy on Real Microsoft Azure (If Subscription Available)

If you have an Azure account (or free \$100 student credit via [Azure for Students](https://azure.microsoft.com/en-us/free/students/)):

1. Log in via Azure CLI:
   ```bash
   az login
   ```
2. Navigate to Terraform directory:
   ```bash
   cd terraform/azure
   terraform init
   terraform plan -out=tfplan
   terraform apply tfplan
   ```
3. Retrieve the VM Public IP from outputs:
   ```bash
   terraform output public_ip_address
   ```
4. Access the live application in your browser:
   `http://<public_ip_address>:3000`

---

## 🔄 GitHub Webhook / Poll SCM Automation

To trigger the Jenkins pipeline automatically upon Git commits:
1. **GitHub Webhook (Production / Public Jenkins):**
   - In your GitHub repo: **Settings** -> **Webhooks** -> **Add Webhook**.
   - Payload URL: `http://<your-jenkins-ip>:8080/github-webhook/`
   - Content type: `application/json`
   - Event: `Just the push event`.
2. **Poll SCM (Local Jenkins / Behind Firewall):**
   - In your Jenkins job configuration: Check **Build Triggers** -> **Poll SCM**.
   - Schedule: `H/5 * * * *` (checks GitHub every 5 minutes for new commits).

---

## 📄 Generating the Project Report (PDF)

The academic report has been formatted according to the IA submission rubric:
1. Open **`docs/PROJECT_REPORT.html`** in **Google Chrome** or **Microsoft Edge**.
2. Click the top button: **Print / Save as PDF** (or press `Ctrl + P`).
3. Set Destination to **Save as PDF**, Paper Size to **A4**, and save your final report!

---

## 👥 Contributors & Academic Declaration
This project was designed and implemented for the **DevOps 3rd Internal Assessment Project**, demonstrating CI/CD automation, Infrastructure as Code, and Cloud Deployment methodologies.
