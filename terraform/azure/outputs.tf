output "resource_group_name" {
  description = "The name of the provisioned Azure Resource Group"
  value       = azurerm_resource_group.devops_rg.name
}

output "azure_region" {
  description = "Azure datacenter region"
  value       = azurerm_resource_group.devops_rg.location
}

output "virtual_network_name" {
  description = "Name of the provisioned VNet"
  value       = azurerm_virtual_network.devops_vnet.name
}

output "subnet_name" {
  description = "Name of the subnet"
  value       = azurerm_subnet.devops_subnet.name
}

output "public_ip_address" {
  description = "Public IP Address assigned to the Azure VM"
  value       = azurerm_public_ip.devops_public_ip.ip_address
}

output "ssh_command" {
  description = "Command to SSH directly into the Azure Virtual Machine"
  value       = "ssh -i id_rsa ${var.admin_username}@${azurerm_public_ip.devops_public_ip.ip_address}"
}

output "web_application_url" {
  description = "Live Web Application URL accessible from browser"
  value       = "http://${azurerm_public_ip.devops_public_ip.ip_address}:3000"
}
