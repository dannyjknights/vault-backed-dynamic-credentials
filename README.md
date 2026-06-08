# Vault-Backed Dynamic Credentials with HCP Terraform and Azure

This repository contains Terraform code to configure a trust relationship between HashiCorp Vault, HCP Terraform, and Azure, enabling Vault-backed dynamic credentials for Azure provider authentication. A basic hub and spoke network architecture is then deployed using those dynamic credentials.

## Overview

Rather than storing long-lived Azure credentials in HCP Terraform, this project uses Vault's Azure secrets engine to generate short-lived, just-in-time credentials for each Terraform run. HCP Terraform authenticates to Vault using workload identity (JWT), Vault generates a dynamic Azure service principal, and that SP is used to authenticate the `azurerm` provider for the duration of the run.

```
HCP Terraform ──JWT──▶ Vault ──dynamic SP──▶ Azure
                         │
                    Azure Secrets Engine
                    (tfc-vault-azure-role)
```

## Repository Structure

```
├── vault-terraform-setup/        # Vault and HCP Terraform configuration
├── hub/                          # Hub network workspace
└── spoke/                        # Spoke network workspace
└── azure-sentinel-policies/      # HashiCorp Sentinel Policies
```

### vault-terraform-setup

Configures the trust relationship between HCP Terraform and Vault, and sets up the Azure secrets engine. This includes:

- JWT auth backend in Vault with HCP Terraform as the OIDC provider
- Vault policy granting access to the Azure secrets engine
- Azure secrets engine and role (`tfc-vault-azure-role`) scoped to the target resource group
- HCP Terraform workspaces for hub and spoke with the required variable sets
- Azure AD application and service principal (`tfc-application`) with the necessary Graph API permissions for dynamic SP creation

### hub

Deploys a basic hub virtual network in Azure. Outputs are published via `tfe_outputs` for consumption by the spoke workspace.

### spoke

Deploys a spoke virtual network and peers it to the hub. Consumes hub outputs using the `tfe_outputs` data source.

### azure-sentinel-policies

Three basic Sentinel policies are created to: 

- Require all resources come from a Private Module Registry
- Restrict the dates that applies can be made
- Restrict inbound source IP addresses

## Prerequisites

- HCP Terraform account with an organisation and project
- HCP Vault cluster (or self-hosted Vault)
- Azure subscription with sufficient permissions to create service principals and role assignments
- Terraform CLI and Azure CLI installed locally

## Setup

### 1. Configure Azure prerequisites

The `tfc-application` service principal requires the following permissions:

**Microsoft Graph (application permissions, admin consent required):**
- `Application.ReadWrite.All`
- `GroupMember.ReadWrite.All`

**Azure RBAC:**
- `Owner` at the subscription or resource group scope (required to assign roles to dynamically created service principals)

### 2. Deploy vault-setup

```bash
cd vault-terraform-setup
terraform init
terraform apply
```

This configures Vault, HCP Terraform workspaces, and the Azure secrets engine in one pass.

### 3. Deploy hub

Trigger a run in the HCP Terraform hub workspace, or push changes to the hub directory if connected to VCS.

### 4. Deploy spoke

Once the hub run has completed and outputs are available, trigger a run in the spoke workspace. The spoke uses `tfe_outputs` to read hub outputs directly.

## How Vault-Backed Dynamic Credentials Work

Each HCP Terraform run follows this flow:

1. HCP Terraform generates a signed JWT workload identity token scoped to the workspace
2. The JWT is exchanged with Vault's JWT auth backend for a short-lived Vault token
3. Vault uses the Vault token to generate a dynamic Azure service principal via the Azure secrets engine
4. The `client_id` and `client_secret` are injected into the run environment as `ARM_CLIENT_ID` and `ARM_CLIENT_SECRET`
5. The `azurerm` provider picks these up automatically and authenticates to Azure
6. At the end of the run, Vault revokes the credentials

## Key Environment Variables

The following variables are set on each HCP Terraform workspace via variable sets:

| Variable | Description |
|---|---|
| `TFC_VAULT_ADDR` | Address of the Vault cluster |
| `TFC_VAULT_NAMESPACE` | Vault namespace (e.g. `admin`) |
| `TFC_VAULT_PROVIDER_AUTH` | Set to `true` to enable Vault auth |
| `TFC_VAULT_RUN_ROLE` | JWT auth role in Vault |
| `TFC_VAULT_BACKED_AZURE_AUTH` | Set to `true` to enable Azure dynamic creds |
| `TFC_VAULT_BACKED_AZURE_RUN_VAULT_ROLE` | Azure secrets engine role in Vault |
| `TFC_VAULT_BACKED_AZURE_SLEEP_SECONDS` | Wait time after credential generation to allow Azure AD propagation |

## Provider Configuration

The `azurerm` provider is configured to receive credentials from Vault via HCP Terraform. Do not set `client_id`, `use_oidc`, or `oidc_token` in the provider block:

```hcl
provider "azurerm" {
  features {}
  use_cli         = false
  subscription_id = var.subscription_id
  tenant_id       = var.tenant_id
}
```

## Notes

- The Azure secrets engine is configured with `application_object_id` to reuse an existing service principal rather than creating a new one per run, avoiding Entra ID propagation race conditions
- `TFC_VAULT_BACKED_AZURE_SLEEP_SECONDS` is set to mitigate eventual consistency delays in Azure AD after credential generation
- Credentials are valid only for the duration of the plan or apply phase and are automatically revoked by Vault afterwards
