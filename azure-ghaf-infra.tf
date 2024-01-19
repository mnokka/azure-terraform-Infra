terraform {
  required_providers {
    azurerm = {
      source = "hashicorp/azurerm"
    }
  }
}
provider "azurerm" {
  features {}
}
# Backend for storing tfstate (see ./azure-storage)
terraform {
  backend "azurerm" {
    resource_group_name  = "az-tf-infra-storage"
    storage_account_name = "azitfinfrastatestorage"
    container_name       = "az-if-infra-tfstate-container"
    key                  = "az-tf-infra.tfstate"
  }
}
# Resource group
resource "azurerm_resource_group" "az_tf_infra" {
  name     = "az-tf-infra"
  location = "swedencentral"
}
# Virtual Network
resource "azurerm_virtual_network" "az_tf_infra_vnet" {
  name                = "az-tf-infra-vnet"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.az_tf_infra.location
  resource_group_name = azurerm_resource_group.az_tf_infra.name
}
# Subnet
resource "azurerm_subnet" "az_tf_infra_subnet" {
  name                 = "az-tf-infra-subnet"
  resource_group_name  = azurerm_resource_group.az_tf_infra.name
  virtual_network_name = azurerm_virtual_network.az_tf_vnet.name
  address_prefixes     = ["10.0.2.0/24"]
}
# Availability Set
resource "azurerm_availability_set" "az_tf_infra_availability_set" {
  name                         = "az-tf-infra-availability-set"
  location                     = azurerm_resource_group.az_tf_infra.location
  resource_group_name          = azurerm_resource_group.az_tf_infra.name
  platform_fault_domain_count  = 2
  platform_update_domain_count = 2
}
# Network Security Group and Rule
resource "azurerm_network_security_group" "az_tf_infra_nsg" {
  name                = "az-tf-infra-nsg"
  location            = azurerm_resource_group.az_tf_infra.location
  resource_group_name = azurerm_resource_group.az_tf_infra.name
  security_rule {
    name                       = "SSH"
    priority                   = 300
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

# Public IP
resource "azurerm_public_ip" "az_tf_infra_public_ip" {
  name                = "az-tf-infra-public-ip"
  domain_name_label   = "aztfinfra"
  location            = azurerm_resource_group.az_tf_infra.location
  resource_group_name = azurerm_resource_group.az_tf_infra.name
  allocation_method   = "Static"
}
# Network interface
resource "azurerm_network_interface" "az_tf_infra_network_interface" {
  name                = "az-tf-infra-net-int"
  location            = azurerm_resource_group.az_tf_infra.location
  resource_group_name = azurerm_resource_group.az_tf_infra.name
  ip_configuration {
    name                          = "az_tf_infra_nic_configuration"
    subnet_id                     = azurerm_subnet.az_tf_infra_subnet.id
    private_ip_address_allocation = "Static"
    private_ip_address            = "10.0.2.4"
    public_ip_address_id          = azurerm_public_ip.az_tf_infra_public_ip.id
  }
}


# aztfinfra_vm VM
resource "azurerm_linux_virtual_machine" "aztfinfra_vm" {
  name                = "aztfinfra"
  location            = azurerm_resource_group.az_tf_infra.location
  resource_group_name = azurerm_resource_group.az_tf_infra.name
  network_interface_ids = [
    azurerm_network_interface.az_tf_infra_network_interface.id
  ]
  size = "Standard_B8ms"
  os_disk {
    name                 = "aztfinfra-disk"
    caching              = "ReadWrite"
    storage_account_type = "Premium_LRS"
    disk_size_gb         = 512
  }
  source_image_reference {
    publisher = "canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts-gen2"
    version   = "latest"
  }
  admin_username                  = "karim"
  disable_password_authentication = true
  admin_ssh_key {
   username   = "karim"
    public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDe5L8iOqhNPsYz5eh9Bz/URYguG60JjMGmKG0wwLIb6Gf2M8Txzk24ESGbMR/F5RYsV1yWYOocL47ngDWQIbO6MGJ7ftUr7slWoUA/FSVwh/jsG681mRqIuJXjKM/YQhBkI9k6+eVxRfLDTs5XZfbwdm7T4aP8ZI2609VY0guXfa/F7DSE1BxN7IJMn0CWLQJanBpoYUxqyQXCUXgljMokdPjTrqAxlBluMsVTP+ZKDnjnpHcVE/hCKk5BxaU6K97OdeIOOEWXAd6uEHssomjtU7+7dhiZzjhzRPKDiSJDF9qtIw50kTHz6ZTdH8SAZmu0hsS6q8OmmDTAnt24dFJV karim@nixos"
  }
}