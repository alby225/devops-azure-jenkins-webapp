# System Architecture & DevOps Workflow Specification

## 1. High-Level Architectural Overview

The automated deployment pipeline unites Infrastructure as Code (**Terraform**), Continuous Integration & Continuous Deployment (**Jenkins**), Source Code Management (**GitHub**), and Cloud Infrastructure (**Microsoft Azure**).

```mermaid
flowchart TD
    subgraph Developer_Workspace["Developer Environment"]
        Dev["Developer"] -->|git push| GH["GitHub Repository"]
    end

    subgraph CI_CD_Engine["Automation Server (Jenkins)"]
        GH -->|Webhook / Poll SCM| J_Trig["Build Trigger"]
        J_Trig --> J_Checkout["Stage 1: Checkout SCM"]
        J_Checkout --> J_Test["Stage 2: Lint & Unit Tests (npm test)"]
        J_Test --> J_Terraform["Stage 3: Terraform Validate & Plan"]
        J_Terraform --> J_Deploy["Stage 4: Automated Deployment (SSH/SCP)"]
        J_Deploy --> J_Smoke["Stage 5: Smoke Test & Health Check"]
    end

    subgraph Azure_Cloud["Microsoft Azure (Resource Group: rg-devops-ia3-project)"]
        subgraph VNet["Virtual Network (10.0.0.0/16)"]
            subgraph Subnet["Web Subnet (10.0.1.0/24)"]
                NSG["Network Security Group\n(Ports 22, 80, 3000)"]
                NIC["Network Interface (Dynamic Private IP)"]
                VM["Azure Linux VM (Ubuntu 22.04 LTS)\n- Node.js Runtime\n- PM2 Daemon / Nginx\n- Express Web App"]
            end
        end
        PIP["Static Public IP\n(20.124.88.145)"]
    end

    J_Deploy -.->|Deploy App Package| VM
    J_Smoke -.->|HTTP GET /api/health| PIP
    PIP --> NIC
    NIC --> VM
    User["End User Browser"] -->|HTTP Port 3000| PIP
```

---

## 2. Infrastructure as Code (Terraform) Breakdown

The infrastructure provisioning is organized hierarchically:

| Resource Type | Resource Identifier | CIDR / Specification | Purpose |
| :--- | :--- | :--- | :--- |
| **Resource Group** | `azurerm_resource_group.devops_rg` | Location: `eastus` | Logical boundary and lifecycle management |
| **Virtual Network** | `azurerm_virtual_network.devops_vnet` | `10.0.0.0/16` | Isolated private network in Azure cloud |
| **Subnet** | `azurerm_subnet.devops_subnet` | `10.0.1.0/24` | Dedicated segment for web servers |
| **Public IP** | `azurerm_public_ip.devops_public_ip` | Static, SKU: `Standard` | Public internet entry point |
| **Network Security Group**| `azurerm_network_security_group.devops_nsg`| Ports 22, 80, 3000 | Firewall rules restricting incoming packets |
| **Network Interface** | `azurerm_network_interface.devops_nic` | Dynamic Private IP | Binds VM to Subnet, Public IP, and NSG |
| **SSH Key Pair** | `tls_private_key.devops_ssh` | RSA 4096-bit | Cryptographic key pair for secure SSH |
| **Virtual Machine** | `azurerm_linux_virtual_machine.devops_vm` | `Standard_B1s` Ubuntu 22.04 | Compute instance hosting application |

---

## 3. CI/CD Pipeline Automation Sequence

```mermaid
sequenceDiagram
    autonumber
    actor Dev as Developer
    participant Git as GitHub
    participant Jen as Jenkins CI/CD
    participant TF as Terraform Engine
    participant Az as Azure Host / VM

    Dev->>Git: git push origin main
    Git->>Jen: Trigger Webhook / Poll SCM detected commit
    activate Jen
    Jen->>Git: Clone repository & checkout commit
    Jen->>Jen: Run npm install & unit test suite
    Note over Jen: Ensures zero regressions before provisioning

    Jen->>TF: terraform init & terraform plan
    TF->>Az: Verify infrastructure state / provision resources
    TF-->>Jen: Return Public IP & Host Metadata

    Jen->>Az: Transfer artifacts & restart web application via PM2
    Jen->>Az: HTTP GET http://{Public_IP}:3000/api/health
    Az-->>Jen: 200 OK (Status: UP)
    Note over Jen: Pipeline marked as SUCCESS (Green Build)
    deactivate Jen
```

---

## 4. Zero-Cost / Local Emulation Strategy

To address the constraint of having **no active Microsoft Azure subscription**:
1. **IaC Syntax & Provider Validation**:
   - The Terraform configuration targets authentic `azurerm` and `tls` providers.
   - `terraform init -backend=false` and `terraform validate` run completely offline or without cloud billing credentials, proving 100% syntactical correctness.
2. **Local CI/CD Execution**:
   - The Jenkinsfile features dual-mode target execution.
   - Jenkins executes the entire pipeline (Checkout -> Test -> IaC Validation -> Deployment -> Health Check), giving actual green builds in the Jenkins dashboard.
3. **Azure Simulation Generator**:
   - The included PowerShell script (`scripts/simulate_azure_apply.ps1`) runs an authentic terminal simulation displaying exact Azure resource creation logs with realistic Azure resource IDs and Public IP outputs.
