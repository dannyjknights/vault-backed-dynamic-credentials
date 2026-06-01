data "tfe_outputs" "hub" {
  workspace    = var.hub_workspace_name
  organization = var.tf_org_name
}

resource "azurerm_resource_group" "spoke_rg" {
  location = "UK South"
  name     = "rg-spoke-networking"
}

resource "azurerm_subnet" "spoke_a_subnets" {
  name                 = "spoke-a-subnet-1"
  resource_group_name  = data.tfe_outputs.hub.values.hub_resource_group
  virtual_network_name = data.tfe_outputs.hub.values.hub_virtual_network
  address_prefixes     = ["172.16.10.0/24"]
}