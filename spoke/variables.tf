variable "hub_workspace_name" {
  description = "The name of the Hub Terraform Cloud/Enterprise workspace."
  type        = string
  default     = "azure-hub-workspace"
}

variable "tf_org_name" {
  description = "The name of the Terraform Cloud/Enterprise organization."
  type        = string
  default     = "danny-hashicorp"
}