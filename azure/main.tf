# We strongly recommend using the required_providers block to set the
# Azure Provider source and version being used
terraform {
  required_version = ">= 0.15"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "=2.59.0"
    }
    cloudinit = {
      source  = "hashicorp/cloudinit"
      version = "2.2.0"
    }
  }
}

# Configure the Microsoft Azure Provider
provider "azurerm" {
  features {}
}

# -----------------------------
# RESOURCE GROUPS
# -----------------------------
resource "azurerm_resource_group" "rg" {
  name     = "rg"
  location = var.location
  tags     = local.eth_tags
}

# -----------------------------
# VIRTUAL NETWORK
# -----------------------------
resource "azurerm_virtual_network" "vn" {
  name                = "vn"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  address_space       = [var.cidrblock]

  tags = local.eth_tags
}

locals {
  eth_tags = {
    crypto = "ethereum"
  }
}
