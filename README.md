# tf-mod-azure-defender

Unified Terraform module for Microsoft Defender for Cloud — supports both **subscription-level plans** and **per-resource** Defender enablement in a single module.

## Features

| Capability | Scope | Resource |
|---|---|---|
| Defender Plans (16 types — see table below) | Subscription | `azurerm_security_center_subscription_pricing` |
| Security Contact Alerts | Subscription | `azurerm_security_center_contact` |
| Security Center Settings (MDE, MCAS, Sentinel) | Subscription | `azurerm_security_center_setting` |
| Microsoft Cloud Security Benchmark (MCSB) | Subscription | `azurerm_subscription_policy_assignment` |
| Log Analytics Workspace Integration | Subscription | `azurerm_security_center_workspace` |
| Workflow Automation & Continuous Export | Subscription | `azurerm_security_center_automation` |
| Defender for Storage (malware scanning, sensitive data) | Per-Resource | `azurerm_security_center_storage_defender` |
| Advanced Threat Protection (Key Vaults, Cosmos DB) | Per-Resource | `azurerm_advanced_threat_protection` |

### Supported Defender Plan Service Types

| `resource_type` | Service |
|---|---|
| `VirtualMachines` | Servers |
| `AppServices` | App Service |
| `SqlServers` | Azure SQL Databases |
| `SqlServerVirtualMachines` | SQL on VMs |
| `OpenSourceRelationalDatabases` | PostgreSQL, MySQL, MariaDB |
| `CosmosDbs` | Azure Cosmos DB |
| `StorageAccounts` | Storage |
| `Containers` | Containers |
| `ContainerRegistry` | Container Registry |
| `KubernetesService` | Kubernetes / AKS |
| `KeyVaults` | Key Vault |
| `Arm` | Resource Manager |
| `Api` | API Management |
| `AI` | Azure AI Services |
| `Dns` | DNS |
| `CloudPosture` | Cloud Security Posture Management (CSPM) |

## Usage Examples

### Per-Resource Only 
Enable Defender for one specific storage account and one specific key vault:

```hcl
module "defender" {
  source = "git::https://github.com/opella-innersource/tf-mod-azure-defender.git?ref=v1.0.0"

  # Per-resource: specific storage account with malware scanning
  storage_accounts = [
    {
      storage_account_id = "/subscriptions/xxxx/resourceGroups/rg-prod/providers/Microsoft.Storage/storageAccounts/stproddata"
    }
  ]

  # Per-resource: specific key vault
  advanced_threat_protection_resource_ids = [
    "/subscriptions/xxxx/resourceGroups/rg-prod/providers/Microsoft.KeyVault/vaults/kv-prod-secrets"
  ]
}
```

### Subscription-Level Plans Only

Enable Defender plans across the entire subscription:

```hcl
module "defender" {
  source = "git::https://github.com/opella-innersource/tf-mod-azure-defender.git?ref=v1.0.0"

  defender_plans = [
    { resource_type = "AppServices" },
    { resource_type = "Containers" },
    { resource_type = "VirtualMachines", subplan = "P2" },
    { resource_type = "KeyVaults", subplan = "PerKeyVault" },
    { resource_type = "StorageAccounts", subplan = "DefenderForStorageV2" },
  ]

  security_contact = {
    email = "security-team@company.com"
    phone = "+1-555-0100"
  }

  security_center_settings = {
    WDATP = true
  }

  enable_mcsb_assignment = true
}
```

### Combined: Subscription Plans + Per-Resource Targeting

Full setup with subscription-wide plans AND specific per-resource overrides:

```hcl
module "defender" {
  source = "git::https://github.com/opella-innersource/tf-mod-azure-defender.git?ref=v1.0.0"

  # Subscription-level plans
  defender_plans = [
    { resource_type = "AppServices" },
    { resource_type = "Containers" },
    { resource_type = "VirtualMachines", subplan = "P2" },
    { resource_type = "Arm", subplan = "PerSubscription" },
  ]

  security_contact = {
    email = "security@company.com"
  }

  enable_mcsb_assignment     = true
  log_analytics_workspace_id = "/subscriptions/xxxx/resourceGroups/rg-mgmt/providers/Microsoft.OperationalInsights/workspaces/law-security"

  # Per-resource: specific storage accounts with custom settings
  storage_accounts = [
    {
      storage_account_id                          = "/subscriptions/xxxx/resourceGroups/rg-prod/providers/Microsoft.Storage/storageAccounts/stproddata"
      override_subscription_settings_enabled      = true
      malware_scanning_on_upload_cap_gb_per_month = 100
    },
    {
      storage_account_id              = "/subscriptions/xxxx/resourceGroups/rg-prod/providers/Microsoft.Storage/storageAccounts/stprodsensitive"
      sensitive_data_discovery_enabled = true
    }
  ]

  # Per-resource: specific key vaults and Cosmos DB
  advanced_threat_protection_resource_ids = [
    "/subscriptions/xxxx/resourceGroups/rg-prod/providers/Microsoft.KeyVault/vaults/kv-prod-secrets",
    "/subscriptions/xxxx/resourceGroups/rg-prod/providers/Microsoft.DocumentDB/databaseAccounts/cosmos-prod"
  ]
}
```

### Workflow Automation & Continuous Export

Export security findings to Event Hubs and Log Analytics for downstream automation and alerting:

```hcl
module "defender" {
  source = "git::https://github.com/opella-innersource/tf-mod-azure-defender.git?ref=v1.0.0"

  defender_plans = [
    { resource_type = "VirtualMachines", subplan = "P2" },
    { resource_type = "StorageAccounts", subplan = "DefenderForStorageV2" },
  ]

  # Workflow automation: export findings to Event Hubs for SIEM integration
  automation_rules = [
    {
      name                   = "export-assessments-to-event-hub"
      description            = "Export all assessments to Event Hub"
      event_hubs_resource_id = "/subscriptions/xxxx/resourceGroups/rg-mgmt/providers/Microsoft.EventHub/namespaces/eh-security/eventhubs/defender-findings"
    },
    {
      name                       = "export-alerts-to-log-analytics"
      description                = "Export alerts to Log Analytics workspace"
      log_analytics_workspace_id = "/subscriptions/xxxx/resourceGroups/rg-mgmt/providers/Microsoft.OperationalInsights/workspaces/law-security"
    }
  ]
}
```

## Design Principles

- **Everything is optional** — All variables default to empty/null. Only configure what you need.
- **No resources created if not configured** — Empty `for_each` or `count = 0` means zero resources deployed.
- **Per-resource overrides subscription** — `override_subscription_settings_enabled = true` lets per-resource settings take precedence.

<!-- BEGIN_TF_DOCS -->
<!-- END_TF_DOCS -->
