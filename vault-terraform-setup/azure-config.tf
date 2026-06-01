resource "azurerm_resource_group" "hub_rg" {
  location = "UK South"
  name     = "rg-hub-networking"
}

# Data source used to get information about the current Azure AD tenant.
data "azuread_client_config" "current" {}

# Data source used to get the current subscription's ID.
data "azurerm_subscription" "current" {
}

data "azuread_application_published_app_ids" "well_known" {
}

data "azuread_service_principal" "msgraph" {
  client_id = data.azuread_application_published_app_ids.well_known.result["MicrosoftGraph"]
}

resource "azuread_app_role_assignment" "tfc_msgraph_app_readwrite" {
  app_role_id         = data.azuread_service_principal.msgraph.app_role_ids["Application.ReadWrite.All"]
  principal_object_id = azuread_service_principal.tfc_service_principal.object_id
  resource_object_id  = data.azuread_service_principal.msgraph.object_id
}

resource "azuread_app_role_assignment" "tfc_msgraph_group_readwrite" {
  app_role_id         = data.azuread_service_principal.msgraph.app_role_ids["GroupMember.ReadWrite.All"]
  principal_object_id = azuread_service_principal.tfc_service_principal.object_id
  resource_object_id  = data.azuread_service_principal.msgraph.object_id
}

# Creates an application registration within Azure Active Directory.
resource "azuread_application" "tfc_application" {
  display_name = "tfc-application"
  owners       = [data.azuread_client_config.current.object_id]
}

# Creates a service principal associated with the previously created
# application registration.
resource "azuread_service_principal" "tfc_service_principal" {
  client_id = azuread_application.tfc_application.client_id
}

resource "azuread_application_password" "tfc_app_pw" {
  application_id = azuread_application.tfc_application.id
}

# Creates a role assignment which controls the permissions the service
# principal has within the Azure subscription.
resource "azurerm_role_assignment" "tfc_role_assignment" {
  scope                = data.azurerm_subscription.current.id
  principal_id         = azuread_service_principal.tfc_service_principal.object_id
  role_definition_name = "Owner"
}

# Creates a federated identity credential which ensures that the given
# workspace will be able to authenticate to Azure for the "plan" & "apply" run phases.
resource "azuread_application_flexible_federated_identity_credential" "tfc_flexible_federated_credential" {
  application_id             = azuread_application.tfc_application.id
  display_name               = "tfc-flexible-federated-credential"
  audience                   = var.tfc_azure_audience
  issuer                     = "https://${var.tfc_hostname}"
  claims_matching_expression = "claims['sub'] matches 'organization:${var.tf_org_name}:project:${var.tf_project_name}:workspace:*:run_phase:*'"
}