# Configure the Azure provider
terraform {
  required_providers {
    azapi = {
      source  = "Azure/azapi"
      version = "1.13.1"
    }
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "3.101.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "3.6.1"
    }
  }

  required_version = ">= 1.1.0"
}

provider "azurerm" {
  features {}
}
