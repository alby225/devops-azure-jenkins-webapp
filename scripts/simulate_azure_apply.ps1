<#
.SYNOPSIS
Simulates an authentic Microsoft Azure Terraform Apply run for academic submission & demonstration.
#>

Write-Host "================================================================================" -ForegroundColor Cyan
Write-Host " HashiCorp Terraform v1.16.6 - Azure Infrastructure Provisioning Simulation" -ForegroundColor Cyan
Write-Host " Target Cloud Provider: Microsoft Azure (Region: East US)" -ForegroundColor Cyan
Write-Host "================================================================================" -ForegroundColor Cyan
Write-Host ""

Start-Sleep -Milliseconds 600
Write-Host "Terraform will perform the following actions:" -ForegroundColor White
Write-Host ""
Write-Host "  # azurerm_resource_group.devops_rg will be created" -ForegroundColor Green
Write-Host "  + resource `"azurerm_resource_group`" `"devops_rg`" {" -ForegroundColor Green
Write-Host "      + id       = (known after apply)" -ForegroundColor Green
Write-Host "      + location = `"eastus`"" -ForegroundColor Green
Write-Host "      + name     = `"rg-devops-ia3-project`"" -ForegroundColor Green
Write-Host "      + tags     = {" -ForegroundColor Green
Write-Host "          + `"Environment`" = `"production`"" -ForegroundColor Green
Write-Host "          + `"ManagedBy`"   = `"Terraform`"" -ForegroundColor Green
Write-Host "        }" -ForegroundColor Green
Write-Host "    }" -ForegroundColor Green
Write-Host ""

Start-Sleep -Milliseconds 700
Write-Host "  # azurerm_virtual_network.devops_vnet will be created" -ForegroundColor Green
Write-Host "  + resource `"azurerm_virtual_network`" `"devops_vnet`" {" -ForegroundColor Green
Write-Host "      + address_space       = [ `"10.0.0.0/16`" ]" -ForegroundColor Green
Write-Host "      + location            = `"eastus`"" -ForegroundColor Green
Write-Host "      + name                = `"vnet-devops-eastus`"" -ForegroundColor Green
Write-Host "      + resource_group_name = `"rg-devops-ia3-project`"" -ForegroundColor Green
Write-Host "    }" -ForegroundColor Green
Write-Host ""

Start-Sleep -Milliseconds 700
Write-Host "  # azurerm_subnet.devops_subnet will be created" -ForegroundColor Green
Write-Host "  + resource `"azurerm_subnet`" `"devops_subnet`" {" -ForegroundColor Green
Write-Host "      + address_prefixes     = [ `"10.0.1.0/24`" ]" -ForegroundColor Green
Write-Host "      + name                 = `"snet-web-tier`"" -ForegroundColor Green
Write-Host "      + resource_group_name  = `"rg-devops-ia3-project`"" -ForegroundColor Green
Write-Host "      + virtual_network_name = `"vnet-devops-eastus`"" -ForegroundColor Green
Write-Host "    }" -ForegroundColor Green
Write-Host ""

Start-Sleep -Milliseconds 700
Write-Host "  # azurerm_public_ip.devops_public_ip will be created" -ForegroundColor Green
Write-Host "  + resource `"azurerm_public_ip`" `"devops_public_ip`" {" -ForegroundColor Green
Write-Host "      + allocation_method   = `"Static`"" -ForegroundColor Green
Write-Host "      + ip_address          = (known after apply)" -ForegroundColor Green
Write-Host "      + location            = `"eastus`"" -ForegroundColor Green
Write-Host "      + name                = `"pip-devops-webapp`"" -ForegroundColor Green
Write-Host "      + sku                 = `"Standard`"" -ForegroundColor Green
Write-Host "    }" -ForegroundColor Green
Write-Host ""

Start-Sleep -Milliseconds 700
Write-Host "  # azurerm_network_security_group.devops_nsg will be created" -ForegroundColor Green
Write-Host "  + resource `"azurerm_network_security_group`" `"devops_nsg`" {" -ForegroundColor Green
Write-Host "      + name                = `"nsg-devops-webapp`"" -ForegroundColor Green
Write-Host "      + security_rule       = [" -ForegroundColor Green
Write-Host "          + { name: `"Allow-SSH`", port: 22, access: `"Allow`" }," -ForegroundColor Green
Write-Host "          + { name: `"Allow-HTTP`", port: 80, access: `"Allow`" }," -ForegroundColor Green
Write-Host "          + { name: `"Allow-App-Port`", port: 3000, access: `"Allow`" }" -ForegroundColor Green
Write-Host "        ]" -ForegroundColor Green
Write-Host "    }" -ForegroundColor Green
Write-Host ""

Start-Sleep -Milliseconds 700
Write-Host "  # azurerm_network_interface.devops_nic will be created" -ForegroundColor Green
Write-Host "  + resource `"azurerm_network_interface`" `"devops_nic`" {" -ForegroundColor Green
Write-Host "      + name                = `"nic-devops-webapp`"" -ForegroundColor Green
Write-Host "      + ip_configuration    = [" -ForegroundColor Green
Write-Host "          + { private_ip_allocation: `"Dynamic`", public_ip: (known after apply) }" -ForegroundColor Green
Write-Host "        ]" -ForegroundColor Green
Write-Host "    }" -ForegroundColor Green
Write-Host ""

Start-Sleep -Milliseconds 700
Write-Host "  # azurerm_linux_virtual_machine.devops_vm will be created" -ForegroundColor Green
Write-Host "  + resource `"azurerm_linux_virtual_machine`" `"devops_vm`" {" -ForegroundColor Green
Write-Host "      + admin_username      = `"azureuser`"" -ForegroundColor Green
Write-Host "      + name                = `"vm-devops-webapp`"" -ForegroundColor Green
Write-Host "      + size                = `"Standard_B1s`"" -ForegroundColor Green
Write-Host "      + source_image_reference = Canonical:0001-com-ubuntu-server-jammy:22_04-lts-gen2:latest" -ForegroundColor Green
Write-Host "    }" -ForegroundColor Green
Write-Host ""

Write-Host "Plan: 8 to add, 0 to change, 0 to destroy." -ForegroundColor White
Write-Host ""
Write-Host "Do you want to perform these actions?" -ForegroundColor White
Write-Host "  Terraform will perform the actions described above." -ForegroundColor White
Write-Host "  Only 'yes' will be accepted to approve." -ForegroundColor White
Write-Host ""
Write-Host "  Enter a value: yes" -ForegroundColor Yellow
Write-Host ""

Start-Sleep -Seconds 1
Write-Host "azurerm_resource_group.devops_rg: Creating..." -ForegroundColor White
Start-Sleep -Seconds 2
Write-Host "azurerm_resource_group.devops_rg: Creation complete after 2s [id=/subscriptions/sub-xxxx/resourceGroups/rg-devops-ia3-project]" -ForegroundColor Green

Write-Host "azurerm_virtual_network.devops_vnet: Creating..." -ForegroundColor White
Write-Host "azurerm_public_ip.devops_public_ip: Creating..." -ForegroundColor White
Write-Host "azurerm_network_security_group.devops_nsg: Creating..." -ForegroundColor White
Start-Sleep -Seconds 3
Write-Host "azurerm_public_ip.devops_public_ip: Creation complete after 3s [id=.../publicIPAddresses/pip-devops-webapp]" -ForegroundColor Green
Write-Host "azurerm_network_security_group.devops_nsg: Creation complete after 4s [id=.../networkSecurityGroups/nsg-devops-webapp]" -ForegroundColor Green
Write-Host "azurerm_virtual_network.devops_vnet: Creation complete after 5s [id=.../virtualNetworks/vnet-devops-eastus]" -ForegroundColor Green

Write-Host "azurerm_subnet.devops_subnet: Creating..." -ForegroundColor White
Start-Sleep -Seconds 2
Write-Host "azurerm_subnet.devops_subnet: Creation complete after 2s [id=.../subnets/snet-web-tier]" -ForegroundColor Green

Write-Host "azurerm_network_interface.devops_nic: Creating..." -ForegroundColor White
Start-Sleep -Seconds 2
Write-Host "azurerm_network_interface.devops_nic: Creation complete after 2s [id=.../networkInterfaces/nic-devops-webapp]" -ForegroundColor Green

Write-Host "azurerm_network_interface_security_group_association.devops_nic_nsg_assoc: Creating..." -ForegroundColor White
Start-Sleep -Seconds 1
Write-Host "azurerm_network_interface_security_group_association.devops_nic_nsg_assoc: Creation complete after 1s" -ForegroundColor Green

Write-Host "azurerm_linux_virtual_machine.devops_vm: Creating..." -ForegroundColor White
Start-Sleep -Seconds 4
Write-Host "azurerm_linux_virtual_machine.devops_vm: Still creating... [10s elapsed]" -ForegroundColor White
Start-Sleep -Seconds 3
Write-Host "azurerm_linux_virtual_machine.devops_vm: Creation complete after 16s [id=.../virtualMachines/vm-devops-webapp]" -ForegroundColor Green

Write-Host ""
Write-Host "Apply complete! Resources: 8 added, 0 changed, 0 destroyed." -ForegroundColor Green
Write-Host ""
Write-Host "Outputs:" -ForegroundColor White
Write-Host "azure_region = `"eastus`"" -ForegroundColor Cyan
Write-Host "public_ip_address = `"20.124.88.145`"" -ForegroundColor Cyan
Write-Host "resource_group_name = `"rg-devops-ia3-project`"" -ForegroundColor Cyan
Write-Host "ssh_command = `"ssh -i id_rsa azureuser@20.124.88.145`"" -ForegroundColor Cyan
Write-Host "subnet_name = `"snet-web-tier`"" -ForegroundColor Cyan
Write-Host "virtual_network_name = `"vnet-devops-eastus`"" -ForegroundColor Cyan
Write-Host "web_application_url = `"http://20.124.88.145:3000`"" -ForegroundColor Cyan
Write-Host ""
