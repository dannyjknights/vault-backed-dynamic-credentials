terraform {
  cloud {
    organization = "danny-hashicorp"
    workspaces {
      name = "azure-hub-workspace"
    }
  }

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "4.54.0"
    }
    tfe = {
      source  = "hashicorp/tfe"
      version = ">=0.71.0"
    }
  }
}

provider "azurerm" {
  use_cli = false
  # use_oidc = false
  tenant_id       = var.tenant_id
  subscription_id = var.subscription_id
  features {}
}