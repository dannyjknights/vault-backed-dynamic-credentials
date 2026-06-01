

output "hub_virtual_network" {
  value = azurerm_virtual_network.hub.name
}

# output "project_id" {
#   value = tfe_project.azure_creds_project.id
# }