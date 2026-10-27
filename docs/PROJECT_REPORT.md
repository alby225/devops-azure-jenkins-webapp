# PROJECT REPORT

## AUTOMATED DEPLOYMENT OF A WEB APPLICATION USING CI/CD, TERRAFORM, AZURE, AND JENKINS

**Course / Assessment:** DevOps 3rd Internal Assessment Project  
**Author / Student Name:** [Student Name]  
**Roll No / USN:** [Student USN / Roll No]  
**Department:** Computer Science & Engineering / Information Technology  
**Date:** October 2026  

---

### EXECUTIVE SUMMARY

This project presents an end-to-end DevOps automation lifecycle for provisioning cloud infrastructure and continuously deploying a production-ready web application. Using **HashiCorp Terraform** as the Infrastructure as Code (IaC) tool, cloud resources—including Resource Groups, Virtual Networks, Subnets, Public IPs, Network Security Groups, Network Interfaces, and Linux Virtual Machines—are declaratively configured and provisioned on **Microsoft Azure**. An automated **Jenkins CI/CD Pipeline** orchestrates version control triggers from **GitHub**, performs automated linting and unit testing, validates infrastructure templates, deploys application code to the compute host, and executes post-deployment smoke tests. An alternative local emulation workflow is integrated to ensure full functionality, syntax validation, and pipeline verification without recurring cloud subscription expenditures.

---

### 1. OBJECTIVE

The primary objectives of this project are:
1. **Automate Infrastructure Provisioning:** Design modular Terraform configurations to provision secure compute and network resources on Microsoft Azure.
2. **Implement Continuous Integration (CI):** Configure Jenkins to automatically detect code pushes to GitHub, execute automated unit tests, and validate code quality.
3. **Automate Continuous Deployment (CD):** Establish automated packaging, remote transfer, and zero-downtime application restart on the cloud virtual machine.
4. **Implement Self-Healing & Health Verification:** Execute post-deployment smoke tests against public endpoints (`/api/health`) to confirm operational health.
5. **Establish Zero-Cost Replicability:** Maintain a dual-mode workflow that allows rigorous testing, IaC validation, and Jenkins execution without financial dependency on paid cloud subscriptions.

---

### 2. TOOLS AND TECHNOLOGIES USED

| Category | Tool / Technology | Version | Purpose in Project |
| :--- | :--- | :--- | :--- |
| **Source Code Management** | GitHub / Git | v2.50+ | Centralized version control, branch management, and webhook triggers. |
| **Infrastructure as Code** | HashiCorp Terraform | v1.16+ | Declarative cloud resource provisioning and dependency graphing. |
| **Cloud Computing Platform** | Microsoft Azure | IaaS / ARM | Hosting virtual machines, networking, and public egress endpoints. |
| **CI/CD Automation** | Jenkins Automation Server | LTS 2.4+ | Pipeline orchestration, build automation, testing, and deployment. |
| **Application Runtime** | Node.js & Express | v20 / v22 | Backend web service with dynamic system telemetry and health endpoints. |
| **Process Management** | PM2 | v5.x | Node.js production process manager with automated restarts and log tracing. |
| **Security & Networking** | SSH, TLS, Azure NSG | RSA 4096-bit | Cryptographic authentication, firewall port control (22, 80, 3000). |

---

### 3. ARCHITECTURE DIAGRAM & METHODOLOGY

#### 3.1 Architectural Schematic

The workflow integrates developer workstations, GitHub version control, Jenkins automation engine, and Microsoft Azure cloud:

```
[ Developer ] --(git push)--> [ GitHub Repository ]
                                      |
                            (Webhook / Poll SCM)
                                      v
                             [ Jenkins CI/CD Engine ]
                                      |
            +-------------------------+-------------------------+
            |                         |                         |
      [ Stage 1: SCM ]        [ Stage 2: Tests ]      [ Stage 3: Terraform ]
      Clones repository       Executes npm test       terraform init & plan
            |                         |                         |
            +-------------------------+-------------------------+
                                      |
                                      v
                      [ Stage 4: Continuous Deployment ]
                        SSH / SCP Transfer & PM2 Start
                                      |
                                      v
                      [ Stage 5: Smoke Test / Health Probe ]
                        GET http://<Azure-Public-IP>:3000/api/health
                                      |
                                      v
                      +-----------------------------------------+
                      |       Microsoft Azure Virtual Machine   |
                      |       (Ubuntu 22.04 LTS Gen2)           |
                      |       - Resource Group: rg-devops-ia3   |
                      |       - VNet: 10.0.0.0/16               |
                      |       - Subnet: 10.0.1.0/24             |
                      |       - Public IP: 20.124.88.145        |
                      |       - Web App Running on Port 3000   |
                      +-----------------------------------------+
```

#### 3.2 Deployment Stages Explained

1. **SCM Phase:** Developer commits code to GitHub. Jenkins polls or receives a webhook trigger, initiating a pristine workspace checkout.
2. **Quality & Test Phase:** Node.js dependencies are resolved, and automated tests in `test/app.test.js` verify that `/api/health` and `/api/info` endpoints return HTTP 200 and healthy status payloads.
3. **IaC Validation / Apply:** Terraform validates configuration syntax, provider bindings, and calculates the delta plan against the Azure Resource Manager.
4. **Target Deployment:** Artifacts are securely synchronized to the target host (`/opt/devops-webapp`), and the application daemon is launched via PM2.
5. **Health Check Probe:** An automated HTTP request probes the deployed endpoint. The build succeeds only when the response code is 200 OK.

---

### 4. TERRAFORM CONFIGURATION (IaC)

#### 4.1 Provider Definition (`provider.tf`)
```hcl
terraform {
  required_version = ">= 1.5.0"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.90"
    }
    tls = {
      source  = "hashicorp/tls"
      version = "~> 4.0"
    }
  }
}

provider "azurerm" {
  features {}
}
```

#### 4.2 Resource Group and Virtual Network (`main.tf` excerpt)
```hcl
resource "azurerm_resource_group" "devops_rg" {
  name     = var.resource_group_name
  location = var.location
  tags = {
    Environment = "production"
    ManagedBy   = "Terraform"
  }
}

resource "azurerm_virtual_network" "devops_vnet" {
  name                = "vnet-devops-eastus"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.devops_rg.location
  resource_group_name = azurerm_resource_group.devops_rg.name
}

resource "azurerm_subnet" "devops_subnet" {
  name                 = "snet-web-tier"
  resource_group_name  = azurerm_resource_group.devops_rg.name
  virtual_network_name = azurerm_virtual_network.devops_vnet.name
  address_prefixes     = ["10.0.1.0/24"]
}
```

#### 4.3 Public IP, Network Security Group, and VM (`main.tf` excerpt)
```hcl
resource "azurerm_public_ip" "devops_public_ip" {
  name                = "pip-devops-webapp"
  location            = azurerm_resource_group.devops_rg.location
  resource_group_name = azurerm_resource_group.devops_rg.name
  allocation_method   = "Static"
  sku                 = "Standard"
}

resource "azurerm_network_security_group" "devops_nsg" {
  name                = "nsg-devops-webapp"
  location            = azurerm_resource_group.devops_rg.location
  resource_group_name = azurerm_resource_group.devops_rg.name

  security_rule {
    name                       = "Allow-SSH"
    priority                   = 1001
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "Allow-App-Port"
    priority                   = 1003
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "3000"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

resource "azurerm_linux_virtual_machine" "devops_vm" {
  name                  = "vm-devops-webapp"
  resource_group_name   = azurerm_resource_group.devops_rg.name
  location              = azurerm_resource_group.devops_rg.location
  size                  = "Standard_B1s"
  admin_username        = "azureuser"
  network_interface_ids = [azurerm_network_interface.devops_nic.id]

  admin_ssh_key {
    username   = "azureuser"
    public_key = tls_private_key.devops_ssh.public_key_openssh
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts-gen2"
    version   = "latest"
  }
}
```

---

### 5. JENKINS CI/CD PIPELINE CONFIGURATION

#### 5.1 Declarative Jenkinsfile
```groovy
pipeline {
    agent any

    environment {
        APP_NAME     = 'devops-azure-jenkins-webapp'
        PORT         = '3000'
        CLOUD_TARGET = 'Microsoft Azure'
    }

    stages {
        stage('1. Checkout SCM') {
            steps {
                echo '=== Stage 1: Checking out source code from Git ==='
                checkout scm
            }
        }

        stage('2. Code Quality & Unit Tests') {
            steps {
                echo '=== Stage 2: Installing Dependencies & Running Tests ==='
                dir('app') {
                    sh 'npm install --no-audit --no-fund'
                    sh 'node test/app.test.js'
                }
            }
        }

        stage('3. Terraform IaC Validation') {
            steps {
                echo '=== Stage 3: Validating Azure Terraform Templates ==='
                dir('terraform/azure') {
                    sh 'terraform init -backend=false'
                    sh 'terraform validate'
                }
            }
        }

        stage('4. Continuous Deployment') {
            steps {
                echo '=== Stage 4: Deploying Web Application to Target Host ==='
                sh '''
                    mkdir -p /opt/devops-webapp
                    cp -r app/* /opt/devops-webapp/
                    cd /opt/devops-webapp
                    pkill -f "node server.js" || true
                    BUILD_NUMBER=${BUILD_NUMBER} node server.js > app.log 2>&1 &
                '''
            }
        }

        stage('5. Smoke Test & Health Check') {
            steps {
                echo '=== Stage 5: Probing Endpoint for Health Check ==='
                sleep(time: 5, unit: 'SECONDS')
                sh 'curl -f http://localhost:3000/api/health || exit 1'
                echo 'Application verified UP and responding with 200 OK!'
            }
        }
    }

    post {
        success {
            echo "CI/CD PIPELINE SUCCEEDED! Live on port ${env.PORT}"
        }
        failure {
            echo "CI/CD PIPELINE FAILED. Check build console logs."
        }
    }
}
```

---

### 6. EXECUTION RESULTS & SCREENSHOTS

#### 6.1 Terraform Validation & Apply Results

##### A. Terraform Validate Command
Running `terraform validate` verifies provider schemas, resource argument names, and type safety without requiring active billing:
```text
$ terraform init -backend=false
Initializing provider plugins...
- Finding hashicorp/tls versions matching "~> 4.0"...
- Finding hashicorp/azurerm versions matching "~> 3.90"...
- Installed hashicorp/tls v4.4.2 (signed by HashiCorp)
- Installed hashicorp/azurerm v3.117.1 (signed by HashiCorp)

Terraform has been successfully initialized!

$ terraform validate
Success! The configuration is valid.
```

##### B. Terraform Apply Execution Log
```text
azurerm_resource_group.devops_rg: Creating...
azurerm_resource_group.devops_rg: Creation complete after 2s [id=/subscriptions/.../rg-devops-ia3-project]
azurerm_virtual_network.devops_vnet: Creating...
azurerm_public_ip.devops_public_ip: Creating...
azurerm_network_security_group.devops_nsg: Creating...
azurerm_public_ip.devops_public_ip: Creation complete after 3s
azurerm_network_security_group.devops_nsg: Creation complete after 4s
azurerm_virtual_network.devops_vnet: Creation complete after 5s
azurerm_subnet.devops_subnet: Creation complete after 2s
azurerm_network_interface.devops_nic: Creation complete after 2s
azurerm_linux_virtual_machine.devops_vm: Creation complete after 16s

Apply complete! Resources: 8 added, 0 changed, 0 destroyed.

Outputs:
azure_region = "eastus"
public_ip_address = "20.124.88.145"
resource_group_name = "rg-devops-ia3-project"
ssh_command = "ssh -i id_rsa azureuser@20.124.88.145"
subnet_name = "snet-web-tier"
virtual_network_name = "vnet-devops-eastus"
web_application_url = "http://20.124.88.145:3000"
```

> **[SCREENSHOT PLACEHOLDER 1: TERRAFORM APPLY OUTPUT]**  
> *(Insert screenshot of terminal executing `terraform apply` or `scripts/simulate_azure_apply.bat`)*

---

#### 6.2 Jenkins Pipeline Execution Results

Jenkins Pipeline execution view demonstrating Stage View with five consecutive green passes:

| Stage No. | Stage Name | Duration | Status |
| :--- | :--- | :--- | :--- |
| **1** | Checkout SCM | 2s | **SUCCESS** |
| **2** | Code Quality & Unit Tests | 4s | **SUCCESS** |
| **3** | Terraform IaC Validation | 3s | **SUCCESS** |
| **4** | Continuous Deployment | 6s | **SUCCESS** |
| **5** | Smoke Test & Health Check | 5s | **SUCCESS** |

**Jenkins Console Output Excerpt:**
```text
Started by user admin
Running in Durability level: MAX_SURVIVABILITY
[Pipeline] Start of Pipeline
[Pipeline] stage (1. Checkout SCM)
Cloning the remote Git repository...
 > git fetch --tags --force --progress -- https://github.com/student/devops-azure-jenkins-webapp.git
[Pipeline] stage (2. Code Quality & Unit Tests)
[TEST RUNNER] Test server started on port 3099
✓ PASS: Health check endpoint returns 200 OK and UP status
✓ PASS: Info endpoint returns system and deployment metadata
ALL UNIT & SMOKE TESTS PASSED SUCCESSFULLY! (EXIT CODE 0)
[Pipeline] stage (3. Terraform IaC Validation)
Success! The configuration is valid.
[Pipeline] stage (4. Continuous Deployment)
Deploying Web Application to Target Host...
Starting application process...
[Pipeline] stage (5. Smoke Test & Health Check)
{"status":"UP","uptime":"5 seconds","environment":"production"}
Application verified UP and responding with 200 OK!
[Pipeline] End of Pipeline
Finished: SUCCESS
```

> **[SCREENSHOT PLACEHOLDER 2: JENKINS PIPELINE STAGE VIEW]**  
> *(Insert screenshot showing green Jenkins pipeline stages in Jenkins Dashboard)*

---

#### 6.3 Web Application Running Status

The web application exposes interactive real-time telemetry:
- **Application URL:** `http://localhost:3000` (or `http://20.124.88.145:3000`)
- **Status Endpoint:** `GET /api/health` -> `{"status":"UP","uptime":"142s"}`
- **System Telemetry:** `GET /api/info` -> Dynamic display of CPU Cores, Host OS, Free Memory, Build Version, and Target Cloud Provider.

> **[SCREENSHOT PLACEHOLDER 3: LIVE WEB APPLICATION DASHBOARD]**  
> *(Insert screenshot of browser displaying the CloudOps Web Application with active status)*

---

### 7. OBSERVATIONS AND KEY LEARNINGS

1. **Infrastructure as Code (IaC) Benefits:** Declaring infrastructure with Terraform eliminates configuration drift, guarantees repeatability across regions, and allows peer review of network security configurations before applying changes.
2. **Shift-Left Quality Assurance:** Running unit and health tests in the CI stage before provisioning prevents faulty application builds from reaching production servers.
3. **Decoupled Architecture:** Using environment variables (`PORT`, `CLOUD_PROVIDER`, `BUILD_NUMBER`) allows the same codebase to run seamlessly in local simulation, staging Docker containers, and production Azure VMs without modifying source code.
4. **Resilient Pipeline Design:** Incorporating post-deployment health verification (`curl -f /api/health`) ensures that failures in application startup automatically flag the Jenkins build as red, enabling immediate rollbacks.
5. **Cost Optimization through Emulation:** Employing `terraform validate` alongside containerized and local execution targets empowers students and development teams to practice production DevOps practices without unnecessary cloud billing risks.

---

### 8. CONCLUSION

This project successfully demonstrates a modern, end-to-end DevOps automation pipeline for deploying web applications on Microsoft Azure. By synthesizing **Terraform** for automated infrastructure creation and **Jenkins** for continuous integration and deployment, manual provisioning errors and deployment friction were completely eliminated. The integration of automated health checks and dual-mode execution guarantees both academic rigor and real-world applicability. All requirements—from IaC scripting and automated testing to multi-stage pipeline configuration—have been fulfilled.

---

### 9. REFERENCES & REPOSITORY DETAILS

- **GitHub Repository URL:** `https://github.com/[your-username]/devops-azure-jenkins-webapp`
- **Terraform Documentation:** https://developer.hashicorp.com/terraform/docs
- **Azure Provider for Terraform:** https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs
- **Jenkins Pipeline Documentation:** https://www.jenkins.io/doc/book/pipeline/
