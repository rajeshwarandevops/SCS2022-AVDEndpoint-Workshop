## Providers
terraform {
  required_providers {
    azurerm = {
      # Specify what version of the provider we are going to utilise
      source  = "hashicorp/azurerm"
      version = ">= 3.27.0"
    }
  }
}
provider "azurerm" {
  features {
  }
}
## Module Configuration
module "avd-hostpool-module" {
  source = "./modules/avd-hostpool-module"
  # Global Variables 
  location = "uk south"
  dns      = "10.10.10.1"
  hub_vnetid = "/subscriptions/bcf086d6-59ae-4481-b2a1-eddf7d75eeff/resourceGroups/scsavdlab-infra/providers/Microsoft.Network/virtualNetworks/Region1-vnet1-hub"
  hub_vnetname = "region1-vnet1-hub"
  hub_rg = "scsavdlab-infra"
  # Lab Environments
  labs = {
    lab1 = {
      name        = "lab1"
      vnet_cidr   = "10.11.0.0/16"
      subnet_cidr = "10.11.1.0/24"
    }
        lab2 = {
      name        = "lab2"
      vnet_cidr   = "10.12.0.0/16"
      subnet_cidr = "10.12.1.0/24"
    }
        lab3 = {
      name        = "lab3"
      vnet_cidr   = "10.13.0.0/16"
      subnet_cidr = "10.13.1.0/24"
    }
  }
}