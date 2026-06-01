variable "tfc_hostname" {
  description = "The hostname of the Terraform Cloud/Enterprise instance."
  type        = string
  default     = "app.terraform.io"
}

variable "tf_org_name" {
  description = "The name of the Terraform Cloud/Enterprise organization."
  type        = string
  default     = "danny-hashicorp"
}

variable "tf_project_name" {
  description = "The name of the Terraform Cloud/Enterprise project."
  type        = string
  default     = "AzureDeployment"
}

variable "tfc_hub_workspace_name" {
  type        = string
  default     = "azure-hub-workspace"
  description = "Workspace created by Terraform"
}

variable "tfc_spoke_workspace_name" {
  type        = string
  default     = "azure-spoke-workspace"
  description = "Workspace created by Terraform"
}

variable "tfc_second_spoke_workspace_name" {
  type        = string
  default     = "azure-second-spoke-workspace"
  description = "Second workspace created by Terraform"
}

variable "subscription_id" {
  description = "Azure Subscription ID."
  type        = string
}

variable "tenant_id" {
  description = "Azure Tenant ID."
  type        = string
}

variable "client_id" {
  description = "Azure Client ID."
  type        = string
}

variable "app_client_id" {
  description = "Azure Client ID for the application registration created by Terraform"
  type        = string
}

variable "client_secret" {
  description = "Azure Client Secret."
  type        = string
}

variable "app_client_secret" {
  description = "Azure Client Secret for the application registration created by Terraform"
  type        = string
}

variable "vault_addr" {
  description = "The address of the Vault server."
  type        = string
  default     = "https://vault-cluster-public-vault-7925976d.2453f46b.z1.hashicorp.cloud:8200"
}

variable "tfc_role" {
  description = "The Vault role configured for Terraform Cloud authentication."
  type        = string
  default     = "tfc-role"
}

variable "tfc_azure_audience" {
  type        = string
  default     = "api://AzureADTokenExchange"
  description = "The audience value to use in run identity tokens"
}

variable "tfc_vault_audience" {
  type        = string
  default     = "vault.workload.identity"
  description = "The audience value to use in run identity tokens"
}

variable "oauth_token" {
  description = "OAuth Token for GitHub / HCP TF"
  type        = string
}