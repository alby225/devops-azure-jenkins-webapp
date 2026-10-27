variable "resource_group_name" {
  type        = string
  description = "Name of the Azure Resource Group"
  default     = "rg-devops-ia3-project"
}

variable "location" {
  type        = string
  description = "Azure Region for provisioning resources"
  default     = "eastus"
}

variable "vnet_address_space" {
  type        = list(string)
  description = "Address space for the Virtual Network"
  default     = ["10.0.0.0/16"]
}

variable "subnet_address_prefix" {
  type        = list(string)
  description = "Address prefix for the Web subnet"
  default     = ["10.0.1.0/24"]
}

variable "vm_name" {
  type        = string
  description = "Name of the Azure Linux Virtual Machine"
  default     = "vm-devops-webapp"
}

variable "vm_size" {
  type        = string
  description = "Azure VM Size (Cost-effective B-series burstable tier)"
  default     = "Standard_B1s"
}

variable "admin_username" {
  type        = string
  description = "Administrator username for the Linux VM"
  default     = "azureuser"
}

variable "ssh_public_key_path" {
  type        = string
  description = "Path to SSH public key file for VM authentication"
  default     = "~/.ssh/id_rsa.pub"
}

variable "environment" {
  type        = string
  description = "Deployment environment tag"
  default     = "production"
}
