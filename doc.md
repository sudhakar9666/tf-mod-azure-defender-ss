# Azure Defender for Cloud Terraform Module

## Overview

This module deploys and configures **Microsoft Defender for Cloud** resources.

The module is designed as a reusable enterprise Terraform module.

* The module **does not create** Azure resources such as Storage Accounts or Log Analytics Workspaces.
* It configures **existing Azure resources**.
* All environment-specific values are provided by the Infrastructure Team.

---

# Module Inputs

## Defender Plans

Enable Microsoft Defender plans at the subscription level.

### Example

```hcl
defender_plans = [
  {
    resource_type = "VirtualMachines"
    tier          = "Standard"
  },
  {
    resource_type = "KeyVaults"
    tier          = "Standard"
  },
  {
    resource_type = "Containers"
    tier          = "Standard"
  }
]
```

### Skip

```hcl
defender_plans = []
```

---

## Security Contact

Configure Defender for Cloud security contact.

### Example

```hcl
security_contact = {
  name  = "Cloud Security Team"
  email = "security@company.com"
  phone = "+1-111-111-1111"
}
```

### Skip

```hcl
security_contact = null
```

---

## Alert Notifications

```hcl
alert_notifications_enabled = true

alerts_to_admins_enabled = true
```

---

## Security Center Settings

Enable Microsoft Defender integrations.

### Example

```hcl
security_center_settings = {
  WDATP   = true
  MCAS    = true
  Sentinel = true
}
```

### Skip

```hcl
security_center_settings = {}
```

---

## Microsoft Cloud Security Benchmark

Enable MCSB Policy Assignment.

### Example

```hcl
enable_mcsb_assignment = true

mcsb_assignment_name = "mcsb"
```

### Skip

```hcl
enable_mcsb_assignment = false
```

---

## Log Analytics Workspace

Provide an **existing** Log Analytics Workspace Resource ID.

> **Note**
>
> This module **does not create** a Log Analytics Workspace.

### Example

```hcl
log_analytics_workspace_id = "/subscriptions/<subscription-id>/resourceGroups/rg-monitoring/providers/Microsoft.OperationalInsights/workspaces/law-security"
```

### Skip

```hcl
log_analytics_workspace_id = null
```

---

## Defender for Storage

Provide **existing Storage Account names**.

> **Note**
>
> This module uses Terraform data sources to locate the Storage Accounts and enables Microsoft Defender for Storage.

### Example

```hcl
storage_accounts = [
  {
    name                = "stapp001"
    resource_group_name = "rg-storage"
  },
  {
    name                = "stlogs001"
    resource_group_name = "rg-monitoring"
  }
]
```

### Skip

```hcl
storage_accounts = []
```

---

## Advanced Threat Protection

Provide Resource IDs for existing resources.

Supported examples include:

* Key Vault
* Cosmos DB
* Other supported Azure resources

### Example

```hcl
advanced_threat_protection_resource_ids = [
  "/subscriptions/<subscription-id>/resourceGroups/rg-security/providers/Microsoft.KeyVault/vaults/kv-prod"
]
```

### Skip

```hcl
advanced_threat_protection_resource_ids = []
```

---

## Automation Resource Group

Provide the existing Resource Group where Microsoft Defender Automation resources will be created.

### Example

```hcl
automation_resource_group_name = "rg-security"
```

---

## Workflow Automation Rules

Configure optional Defender Workflow Automation.

### Example

```hcl
automation_rules = [
  {
    name        = "export-security-findings"
    enabled     = true
    description = "Export Microsoft Defender findings"

    scopes = [
      "/subscriptions/<subscription-id>"
    ]

    event_hubs_resource_id = "/subscriptions/<subscription-id>/resourceGroups/rg-monitoring/providers/Microsoft.EventHub/namespaces/evh-prod/eventhubs/security"

    log_analytics_workspace_id = "/subscriptions/<subscription-id>/resourceGroups/rg-monitoring/providers/Microsoft.OperationalInsights/workspaces/law-security"
  }
]
```

### Export only to Log Analytics

```hcl
automation_rules = [
  {
    name        = "export-security"
    enabled     = true

    log_analytics_workspace_id = "/subscriptions/<subscription-id>/resourceGroups/rg-monitoring/providers/Microsoft.OperationalInsights/workspaces/law-security"
  }
]
```

### Export only to Event Hub

```hcl
automation_rules = [
  {
    name        = "eventhub-export"
    enabled     = true

    event_hubs_resource_id = "/subscriptions/<subscription-id>/resourceGroups/rg-monitoring/providers/Microsoft.EventHub/namespaces/evh-prod/eventhubs/security"
  }
]
```

### Skip

```hcl
automation_rules = []
```


For existing keyvaults 

key_vaults = [
  {
    name                = "kv-pxyz111"
    resource_group_name = "rg-security"
  },
  {
    name                = "kv-shared"
    resource_group_name = "rg-shared"
  }
]
##for skip
key_vaults = []


## cosmos DB###
cosmosdb_accounts = [
  {
    name                = "cosmos-xyz"
    resource_group_name = "rg-data"
  },
  {
    name                = "cosmos-shared"
    resource_group_name = "rg-platform"
  }
]

# To skip
cosmosdb_accounts = []

