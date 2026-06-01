# resource "azurerm_resource_group" "hub_rg" {
#   location = "UK South"
#   name     = "rg-hub-networking"
# }

data "azurerm_resource_group" "hub_rg" {
  name = "rg-hub-networking"
}

resource "azurerm_virtual_network" "hub" {
  location            = data.azurerm_resource_group.hub_rg.location
  name                = "vnet-hub-networking"
  resource_group_name = data.azurerm_resource_group.hub_rg.name
  address_space       = ["172.16.0.0/16"]
}

resource "azurerm_subnet" "hub_subnets" {
  name                 = "hub-subnet-1"
  resource_group_name  = data.azurerm_resource_group.hub_rg.name
  virtual_network_name = azurerm_virtual_network.hub.name
  address_prefixes     = ["172.16.1.0/24"]
}

resource "azurerm_public_ip" "natgw_public_ip" {
  name                = "natgw-public-ip"
  location            = data.azurerm_resource_group.hub_rg.location
  resource_group_name = data.azurerm_resource_group.hub_rg.name
  allocation_method   = "Static"
  sku                 = "Standard"
}

resource "azurerm_nat_gateway" "nat_gateway" {
  name                = "hub-nat-gateway"
  location            = data.azurerm_resource_group.hub_rg.location
  resource_group_name = data.azurerm_resource_group.hub_rg.name
  sku_name            = "Standard"
}

resource "azurerm_nat_gateway_public_ip_association" "nat_gateway_ip_assoc" {
  nat_gateway_id       = azurerm_nat_gateway.nat_gateway.id
  public_ip_address_id = azurerm_public_ip.natgw_public_ip.id
}

