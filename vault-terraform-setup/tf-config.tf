resource "tfe_project" "azure_creds_project" {
  name         = var.tf_project_name
  organization = var.tf_org_name
  description  = "Azure dynamic credentials"
}

resource "tfe_workspace" "hub_workspace" {
  name         = var.tfc_hub_workspace_name
  organization = var.tf_org_name
  project_id   = tfe_project.azure_creds_project.id
  description  = "Hub workspace with Azure dynamic credentials"
}

resource "tfe_workspace_settings" "hub_workspace_settings" {
  workspace_id        = tfe_workspace.hub_workspace.id
  global_remote_state = true
}

resource "tfe_workspace" "spoke_workspace" {
  name         = var.tfc_spoke_workspace_name
  organization = var.tf_org_name
  project_id   = tfe_project.azure_creds_project.id
  description  = "Spoke workspace with Azure dynamic credentials"
}

resource "tfe_workspace" "new_spoke_workspace" {
  name         = var.tfc_second_spoke_workspace_name
  organization = var.tf_org_name
  project_id   = tfe_project.azure_creds_project.id
  description  = "Azure second spoke workspace"
}

resource "tfe_variable_set" "vault_tf_auth_var_set" {
  name         = "Vault Azure Creds Variable Set"
  organization = var.tf_org_name
  description  = "Variable set for Azure dynamic credentials"
}

resource "tfe_project_variable_set" "vault_tf_auth_var_set_proj" {
  project_id      = tfe_project.azure_creds_project.id
  variable_set_id = tfe_variable_set.vault_tf_auth_var_set.id
}

resource "tfe_workspace_variable_set" "tf_auth_var_set" {
  workspace_id    = tfe_workspace.hub_workspace.id
  variable_set_id = tfe_variable_set.vault_tf_auth_var_set.id
}

resource "tfe_variable" "vault_addr_env_vars" {
  for_each = {
    "TFC_VAULT_ADDR" = var.vault_addr
  }
  key             = each.key
  value           = each.value
  category        = "env"
  hcl             = false
  sensitive       = false
  variable_set_id = tfe_variable_set.vault_tf_auth_var_set.id
  description     = "Vault server address"
}

resource "tfe_variable" "tf_vault_role_env_vars" {
  for_each = {
    "TFC_VAULT_RUN_ROLE" = var.tfc_role
  }
  key             = each.key
  value           = each.value
  category        = "env"
  hcl             = false
  sensitive       = false
  variable_set_id = tfe_variable_set.vault_tf_auth_var_set.id
  description     = "Vault Azure role for Terraform authentication"
}

resource "tfe_variable" "tfc_vault_provider_auth" {
  for_each = {
    "TFC_VAULT_PROVIDER_AUTH" = true
  }
  key             = each.key
  value           = each.value
  category        = "env"
  hcl             = false
  sensitive       = false
  variable_set_id = tfe_variable_set.vault_tf_auth_var_set.id
  description     = "Enable Vault backed tf auth"
}

resource "tfe_variable" "tfc_vault_backed_azure_auth" {
  for_each = {
    "TFC_VAULT_BACKED_AZURE_AUTH" = true
  }
  key             = each.key
  value           = each.value
  category        = "env"
  hcl             = false
  sensitive       = false
  variable_set_id = tfe_variable_set.vault_tf_auth_var_set.id
  description     = "Enable Vault backed Azure auth"
}

resource "tfe_variable" "tfc_vault_backed_azure_run_vault_role" {
  key             = "TFC_VAULT_BACKED_AZURE_RUN_VAULT_ROLE"
  value           = "tfc-vault-azure-role"
  category        = "env"
  hcl             = false
  sensitive       = false
  variable_set_id = tfe_variable_set.vault_tf_auth_var_set.id
  description     = "Vault role to use for Vault backed Azure auth"
}

resource "tfe_variable" "tfc_vault_backed_azure_sleep" {
  key             = "TFC_VAULT_BACKED_AZURE_SLEEP_SECONDS"
  value           = "60"
  category        = "env"
  hcl             = false
  sensitive       = false
  variable_set_id = tfe_variable_set.vault_tf_auth_var_set.id
  description     = "Sleep duration for Vault backed Azure auth"
}

resource "tfe_variable" "vault_namespace" {
  key             = "TFC_VAULT_NAMESPACE"
  value           = "admin"
  category        = "env"
  variable_set_id = tfe_variable_set.vault_tf_auth_var_set.id
  description     = "Vault namespace"
}

resource "tfe_oauth_client" "github_oauth" {
  name             = "azure-demo"
  organization     = var.tf_org_name
  api_url          = "https://api.github.com"
  http_url         = "https://github.com"
  service_provider = "github"
  oauth_token      = var.oauth_token

}

resource "tfe_policy_set" "azure_policy_set" {
  name         = "azure-sentinel-policies"
  description  = "Azure Sentinel Policy Set"
  organization = var.tf_org_name
  kind         = "sentinel"
  vcs_repo {
    identifier     = "dannyjknights/azure-sentinel-policies"
    branch         = "main"
    oauth_token_id = tfe_oauth_client.github_oauth.oauth_token_id
  }
}

resource "tfe_project_policy_set" "azure_policy_set_project" {
  project_id    = tfe_project.azure_creds_project.id
  policy_set_id = tfe_policy_set.azure_policy_set.id
}