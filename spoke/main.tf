terraform {
  cloud {

    organization = "danny-hashicorp"

    workspaces {
      name = "azure-spoke-workspace"
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
  use_cli         = false
  tenant_id       = "b8374b2e-678f-4daa-980b-b8173d05d1aa"
  subscription_id = "0b90a85b-2a48-4332-b873-91fc2aecbaf1"
  features {}
}