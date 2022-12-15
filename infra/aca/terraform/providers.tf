provider "azurerm" {
  features {}
}

terraform {
  backend "azurerm" {
    resource_group_name  = "dfurmidge-rg"
    storage_account_name = "ststatedfurmidge"
    container_name       = "tfstate"
    key                  = "terraform-containerapp.tfstate"
  }

  required_providers {
    azapi = {
      source = "azure/azapi"
    }
  }

}

provider "azapi" {
}

data "azurerm_client_config" "current" {}