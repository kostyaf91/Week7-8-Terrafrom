# Azure provider configuration
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 2.65"
    }
  }

  backend "azurerm" {
    resource_group_name  = "tfstate"
    storage_account_name = "kostyaf91storage"
    container_name       = "tf-state-container"
    key                  = "terraform.tfstate"
  }

}

provider "azurerm" {
  features {}
}
