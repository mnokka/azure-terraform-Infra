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

# Resource group

variable "resource_group_location" {
  type        = string
  default     = "swedencentral"
  description = "Location of the resource group."
}

resource "azurerm_resource_group" "rg" {
  name     = "az-tf-infra-storage"
  location = var.resource_group_location
}


# Create storage container

resource "azurerm_storage_account" "tfstate" {
  name                            = "aztfinfrastatestorage"
  resource_group_name             = azurerm_resource_group.rg.name
  location                        = azurerm_resource_group.rg.location
  account_tier                    = "Standard"
  account_replication_type        = "LRS"
  allow_nested_items_to_be_public = false
}

resource "azurerm_storage_container" "tfstate" {
  name                  = "az-tf-infra-tfstate-container"
  storage_account_name  = azurerm_storage_account.tfstate.name
  container_access_type = "private"
}