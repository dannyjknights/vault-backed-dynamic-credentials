variable "hub_workspace_name" {
  description = "The name of the Hub Terraform Cloud/Enterprise workspace."
  type        = string
}

variable "tf_org_name" {
  description = "The name of the Terraform Cloud/Enterprise organization."
  type        = string
}

variable "tenant_id" {
  description = "The Tenant ID of the Azure Active Directory."
  type        = string
}

variable "subscription_id" {
  description = "The Subscription ID of the Azure subscription."
  type        = string
}