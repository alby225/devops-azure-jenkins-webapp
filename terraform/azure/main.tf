# ==============================================================================
# Azure DevOps Infrastructure as Code (Terraform)
# Provisions: Resource Group, VNet, Subnet, Public IP, NSG, NIC, Linux VM
# ==============================================================================

# 1. Azure Resource Group
resource "azurerm_resource_group" "devops_rg" {
  name     = var.resource_group_name
  location = var.location

  tags = {
    Environment = var.environment
    ManagedBy   = "Terraform"
    Project     = "DevOps-3rd-IA"
  }
}

# 2. Virtual Network (VNet)
resource "azurerm_virtual_network" "devops_vnet" {
  name                = "vnet-devops-eastus"
  address_space       = var.vnet_address_space
  location            = azurerm_resource_group.devops_rg.location
  resource_group_name = azurerm_resource_group.devops_rg.name

  tags = azurerm_resource_group.devops_rg.tags
}

# 3. Subnet for Web Application
resource "azurerm_subnet" "devops_subnet" {
  name                 = "snet-web-tier"
  resource_group_name  = azurerm_resource_group.devops_rg.name
  virtual_network_name = azurerm_virtual_network.devops_vnet.name
  address_prefixes     = var.subnet_address_prefix
}

# 4. Public IP for Virtual Machine
resource "azurerm_public_ip" "devops_public_ip" {
  name                = "pip-devops-webapp"
  location            = azurerm_resource_group.devops_rg.location
  resource_group_name = azurerm_resource_group.devops_rg.name
  allocation_method   = "Static"
  sku                 = "Standard"

  tags = azurerm_resource_group.devops_rg.tags
}

# 5. Network Security Group (NSG) with Inbound Firewall Rules
resource "azurerm_network_security_group" "devops_nsg" {
  name                = "nsg-devops-webapp"
  location            = azurerm_resource_group.devops_rg.location
  resource_group_name = azurerm_resource_group.devops_rg.name

  # Allow SSH Management (Port 22)
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

  # Allow HTTP Traffic (Port 80)
  security_rule {
    name                       = "Allow-HTTP"
    priority                   = 1002
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "80"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  # Allow Web App Custom Port (Port 3000)
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

  tags = azurerm_resource_group.devops_rg.tags
}

# 6. Network Interface (NIC)
resource "azurerm_network_interface" "devops_nic" {
  name                = "nic-devops-webapp"
  location            = azurerm_resource_group.devops_rg.location
  resource_group_name = azurerm_resource_group.devops_rg.name

  ip_configuration {
    name                          = "internal-ip-config"
    subnet_id                     = azurerm_subnet.devops_subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.devops_public_ip.id
  }

  tags = azurerm_resource_group.devops_rg.tags
}

# 7. Associate NSG with Network Interface
resource "azurerm_network_interface_security_group_association" "devops_nic_nsg_assoc" {
  network_interface_id      = azurerm_network_interface.devops_nic.id
  network_security_group_id = azurerm_network_security_group.devops_nsg.id
}

# 8. Generate TLS Private Key for SSH (Self-contained, no external key file required)
resource "tls_private_key" "devops_ssh" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

# Save generated private key locally so student can SSH into VM directly
resource "local_file" "ssh_key" {
  content         = tls_private_key.devops_ssh.private_key_pem
  filename        = "${path.module}/id_rsa"
  file_permission = "0600"
}

# 9. Azure Linux Virtual Machine (Ubuntu 22.04 LTS)
resource "azurerm_linux_virtual_machine" "devops_vm" {
  name                  = var.vm_name
  resource_group_name   = azurerm_resource_group.devops_rg.name
  location              = azurerm_resource_group.devops_rg.location
  size                  = var.vm_size
  admin_username        = var.admin_username
  network_interface_ids = [azurerm_network_interface.devops_nic.id]

  admin_ssh_key {
    username   = var.admin_username
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

  # Cloud-init script: Automatically installs Node.js, Git, PM2 & sets up environment
  custom_data = base64encode(<<-EOF
              #!/bin/bash
              apt-get update -y
              curl -fsSL https://deb.nodesource.com/setup_20.x | bash -
              apt-get install -y nodejs git nginx
              npm install -g pm2
              systemctl enable nginx
              systemctl start nginx
              EOF
  )

  tags = azurerm_resource_group.devops_rg.tags
}
