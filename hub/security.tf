resource "azurerm_network_security_group" "hub_security_group" {
  location            = data.azurerm_resource_group.hub_rg.location
  name                = "hub-security-group"
  resource_group_name = data.azurerm_resource_group.hub_rg.name
}

resource "azurerm_network_security_rule" "allow_ssh_inbound" {
  name                        = "Allow-SSH-Inbound"
  priority                    = 100
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "22"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  network_security_group_name = azurerm_network_security_group.hub_security_group.name
  resource_group_name         = data.azurerm_resource_group.hub_rg.name
}