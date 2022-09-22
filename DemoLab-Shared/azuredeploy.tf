## Providers
terraform {
  required_providers {
    azurerm = {
      # Specify what version of the provider we are going to utilise
      source  = "hashicorp/azurerm"
      version = ">= 3.23.0"
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
  # Lab Environments
  labs = {
    lab1 = {
      name        = "lab1"
      vnet_cidr   = "10.11.0.0/16"
      subnet_cidr = "10.11.1.0/24"
    }
  }
}