terraform {

  required_version = ">= 1.0"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
  }

  backend "azurerm" {
    resource_group_name  = "rg-terraform-mgmt"
    storage_account_name = ""
    container_name       = "tfstate"
    key                  = "omnicode.prod.tfstate"
  }

}
provider "azurerm" {
  features {}
}
