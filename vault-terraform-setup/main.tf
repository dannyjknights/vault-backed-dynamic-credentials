terraform {

  required_providers {
    tfe = {
      source  = "hashicorp/tfe"
      version = ">=0.71.0"
    }
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">=4.44.0"
    }
    vault = {
      source  = "hashicorp/vault"
      version = "5.5.0"
    }
  }
}

provider "tfe" {
  # Configuration options
}

provider "azurerm" {
  features {}
  subscription_id = var.subscription_id
}