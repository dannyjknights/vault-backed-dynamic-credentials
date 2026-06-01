resource "vault_jwt_auth_backend" "tfc_jwt" {
  path               = "jwt"
  type               = "jwt"
  oidc_discovery_url = "https://${var.tfc_hostname}"
  bound_issuer       = "https://${var.tfc_hostname}"
}

resource "vault_jwt_auth_backend_role" "tfc_role" {
  backend        = vault_jwt_auth_backend.tfc_jwt.path
  role_name      = var.tfc_role
  token_policies = [vault_policy.tfc_policy.name]

  bound_audiences   = [var.tfc_vault_audience]
  bound_claims_type = "glob"
  bound_claims = {
    sub = "organization:${var.tf_org_name}:project:${var.tf_project_name}:workspace:*:run_phase:*"
  }
  user_claim = "terraform_full_workspace"
  role_type  = "jwt"
  token_ttl  = 1200
}

resource "vault_policy" "tfc_policy" {
  name = "tfc-policy"

  policy = <<EOT
# Allow tokens to query themselves
path "auth/token/lookup-self" {
  capabilities = ["read"]
}

# Allow tokens to renew themselves
path "auth/token/renew-self" {
    capabilities = ["update"]
}

# Allow tokens to revoke themselves
path "auth/token/revoke-self" {
    capabilities = ["update"]
}

# Configure the actual secrets the token should have access to
path "secret/*" {
  capabilities = ["read"]
}

# Allow access to Azure dynamic credentials
path "azure/creds/tfc-vault-azure-role" {
  capabilities = ["read"]
}
EOT
}

resource "vault_azure_secret_backend" "azure" {
  subscription_id = var.subscription_id
  tenant_id       = var.tenant_id
  client_id       = azuread_application.tfc_application.client_id
  client_secret   = azuread_application_password.tfc_app_pw.value
  # default_lease_ttl_seconds = 1200
  # max_lease_ttl_seconds     = 1200
}

resource "vault_azure_secret_backend_role" "azure" {
  backend               = vault_azure_secret_backend.azure.path
  role                  = "tfc-vault-azure-role"
  application_object_id = azuread_application.tfc_application.object_id
  ttl                   = 300
  max_ttl               = 600

  azure_roles {
    role_name = "Owner"
    scope     = "/subscriptions/${var.subscription_id}/resourceGroups/${azurerm_resource_group.hub_rg.name}"
  }
}