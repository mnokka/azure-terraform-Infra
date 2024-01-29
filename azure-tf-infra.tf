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

# Read SSH from YAML file
locals {
  ssh_keys = yamldecode(file("${path.module}/ssh.yaml"))
}

# Resource group
resource "azurerm_resource_group" "ghaf_az_tf_infra" {
  name     = "ghaf-az-tf-infra"
  location = "swedencentral"
}

# Virtual Network
resource "azurerm_virtual_network" "ghaf_az_tf_infra_vnet" {
  name                = "ghaf-az-tf-infra-vnet"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.ghaf_az_tf_infra.location
  resource_group_name = azurerm_resource_group.ghaf_az_tf_infra.name
}

# Subnet
resource "azurerm_subnet" "ghaf_az_tf_infra_subnet" {
  name                 = "ghaf-az-tf-infra-subnet"
  resource_group_name  = azurerm_resource_group.ghaf_az_tf_infra.name
  virtual_network_name = azurerm_virtual_network.ghaf_az_tf_infra_vnet.name
  address_prefixes     = ["10.0.2.0/24"]
}

# Availability Set
resource "azurerm_availability_set" "ghaf_az_tf_infra_availability_set" {
  name                         = "ghaf-az-tf-infra-availability-set"
  location                     = azurerm_resource_group.ghaf_az_tf_infra.location
  resource_group_name          = azurerm_resource_group.ghaf_az_tf_infra.name
  platform_fault_domain_count  = 2
  platform_update_domain_count = 2
}

# Network Security Group and Rule
resource "azurerm_network_security_group" "ghaf_az_tf_infra_nsg" {
  name                = "ghaf-az-tf-infra-nsg"
  location            = azurerm_resource_group.ghaf_az_tf_infra.location
  resource_group_name = azurerm_resource_group.ghaf_az_tf_infra.name
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
resource "azurerm_public_ip" "ghaf_az_tf_infra_public_ip" {
  name                = "ghaf-az-tf-infra-public-ip"
  domain_name_label   = "ghafaztfinfra"
  location            = azurerm_resource_group.ghaf_az_tf_infra.location
  resource_group_name = azurerm_resource_group.ghaf_az_tf_infra.name
  allocation_method   = "Static"
}

# Network interface
resource "azurerm_network_interface" "ghaf_az_tf_infra_network_interface" {
  name                = "ghaf-az-tf-infra-net-int"
  location            = azurerm_resource_group.ghaf_az_tf_infra.location
  resource_group_name = azurerm_resource_group.ghaf_az_tf_infra.name
  ip_configuration {
    name                          = "ghaf-az_tf_infra_nic_configuration"
    subnet_id                     = azurerm_subnet.ghaf_az_tf_infra_subnet.id
    private_ip_address_allocation = "Static"
    private_ip_address            = "10.0.2.4"
    public_ip_address_id          = azurerm_public_ip.ghaf_az_tf_infra_public_ip.id
  }
}

# Virtual Machine
resource "azurerm_linux_virtual_machine" "ghaf_aztfinfra_vm" {
  name                = "ghaf-aztfinfra"
  location            = azurerm_resource_group.ghaf_az_tf_infra.location
  resource_group_name = azurerm_resource_group.ghaf_az_tf_infra.name
  network_interface_ids = [
    azurerm_network_interface.ghaf_az_tf_infra_network_interface.id
  ]
size                            = "Standard_DS1_v2" 


    os_disk {
    name                 = "ghaf-aztfinfra-disk"
    storage_account_type = "Standard_LRS"
    caching              = "ReadWrite"
  }
  
  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18.04-LTS"
    version   = "latest"
  }
  admin_username                  = "mika"
  disable_password_authentication = true
  admin_ssh_key {
    username   = "mika"
    public_key = local.ssh_keys["mika"]
  }
}

