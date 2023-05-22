# We strongly recommend using the required_providers block to set the
# Azure Provider source and version being used
terraform {
  required_version = ">= 0.15"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "=2.71.0"
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

  subscription_id = "48fd0afc-a663-4ed6-b9c8-cb648e3dcb25"
  tenant_id       = "3c7a9fb7-fd68-4ed3-b0c6-ff9dc05af75f"
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
  defichain_tags = {
    crypto = "defichain"
  }
  theta_tags = {
    crypto = "theta"
  }
  streamr_tags = {
    crypto = "streamr"
  }
}
