provider "azurerm" {
  features {}
}

terraform {
  backend "azurerm" {
    resource_group_name  = "dfurmidge-rg"
    storage_account_name = "ststatedfurmidge"
    container_name       = "tfstate"
    key                  = "terraform-base.tfstate"
  }
}

data "azurerm_client_config" "current" {}