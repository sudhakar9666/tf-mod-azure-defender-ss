data "azurerm_subscription" "current" {}

##Existing Storage Accounts
#----------------------------------------------
data "azurerm_storage_account" "defender_storage_accounts" {
  for_each = {
    for sa in var.storage_accounts : sa.name => sa
  }

  name                = each.value.name
  resource_group_name = each.value.resource_group_name
}

#--------------------------------------------------------------
# Existing Key Vaults
#--------------------------------------------------------------
data "azurerm_key_vault" "existing_key_vaults" {
  for_each = {
    for kv in var.key_vaults : kv.name => kv
  }

  name                = each.value.name
  resource_group_name = each.value.resource_group_name
}

#--------------------------------------------------------------
# Existing Cosmos DB Accounts
#--------------------------------------------------------------
data "azurerm_cosmosdb_account" "existing_cosmosdb_accounts" {
  for_each = {
    for db in var.cosmosdb_accounts : db.name => db
  }

  name                = each.value.name
  resource_group_name = each.value.resource_group_name
}

#--------------------------------------------------------------
# Defender for Cloud — Subscription Pricing (Plans)
#--------------------------------------------------------------
resource "azurerm_security_center_subscription_pricing" "plans" {
  for_each = { for plan in var.defender_plans : plan.resource_type => plan }

  tier          = each.value.tier
  resource_type = each.value.resource_type
  subplan       = each.value.subplan

  dynamic "extension" {
    for_each = each.value.extensions != null ? each.value.extensions : []
    content {
      name                            = extension.value.name
      additional_extension_properties = extension.value.additional_extension_properties
    }
  }
}

#--------------------------------------------------------------
# Security Contact (optional)
#--------------------------------------------------------------
resource "azurerm_security_center_contact" "security_contact" {
  count = var.security_contact != null ? 1 : 0

  email               = var.security_contact.email
  phone               = var.security_contact.phone
  name                = var.security_contact.name
  alert_notifications = var.alert_notifications_enabled
  alerts_to_admins    = var.alerts_to_admins_enabled
}

#--------------------------------------------------------------
# Security Center Settings (MDE / MCAS / Sentinel)
#--------------------------------------------------------------
resource "azurerm_security_center_setting" "settings" {
  for_each = var.security_center_settings

  setting_name = each.key
  enabled      = each.value
}

#--------------------------------------------------------------
# Microsoft Cloud Security Benchmark (MCSB) Policy Assignment
#--------------------------------------------------------------
resource "azurerm_subscription_policy_assignment" "mcsb" {
  count = var.enable_mcsb_assignment ? 1 : 0

  name                 = var.mcsb_assignment_name
  display_name         = "Microsoft Cloud Security Benchmark"
  policy_definition_id = "/providers/Microsoft.Authorization/policySetDefinitions/1f3afdf9-d0c9-4c3d-847f-89da613e70a8"
  subscription_id      = data.azurerm_subscription.current.id
}

#--------------------------------------------------------------
# Log Analytics Workspace Integration (optional)
#--------------------------------------------------------------
resource "azurerm_security_center_workspace" "log_analytics_workspace" {
  count = var.log_analytics_workspace_id != null ? 1 : 0

  scope        = data.azurerm_subscription.current.id
  workspace_id = var.log_analytics_workspace_id
}

#--------------------------------------------------------------
# Defender for Storage — Per-Resource
#--------------------------------------------------------------
resource "azurerm_security_center_storage_defender" "storage_defender" {
  for_each = data.azurerm_storage_account.defender_storage_accounts

  storage_account_id = each.value.id

  override_subscription_settings_enabled      = true
  malware_scanning_on_upload_enabled          = true
  malware_scanning_on_upload_cap_gb_per_month = -1
  sensitive_data_discovery_enabled            = true
}
#--------------------------------------------------------------
# Defender for Key Vault
#--------------------------------------------------------------
resource "azurerm_advanced_threat_protection" "key_vault_defender" {
  for_each = data.azurerm_key_vault.existing_key_vaults

  target_resource_id = each.value.id
  enabled            = true
}

#--------------------------------------------------------------
# Defender for Cosmos DB
#--------------------------------------------------------------
resource "azurerm_advanced_threat_protection" "cosmosdb_defender" {
  for_each = data.azurerm_cosmosdb_account.existing_cosmosdb_accounts

  target_resource_id = each.value.id
  enabled            = true
}
#

#--------------------------------------------------------------
# Security Center Automation Rules (Workflow Automation & Continuous Export)
#--------------------------------------------------------------
resource "azurerm_security_center_automation" "automation_rules" {
  for_each = { for rule in var.automation_rules : rule.name => rule }

  name                = each.value.name
  enabled             = each.value.enabled
  description         = each.value.description
  location            = "eastus"
  resource_group_name = var.automation_resource_group_name

  scopes = each.value.scopes != null ? each.value.scopes : ["/subscriptions/${data.azurerm_subscription.current.subscription_id}"]

  source {
    event_source = "Assessments"
  }

  # Export to Event Hub if provided
  dynamic "action" {
    for_each = each.value.event_hubs_resource_id != null ? [1] : []
    content {
      type        = "EventHub"
      resource_id = each.value.event_hubs_resource_id
    }
  }

  # Export to Log Analytics if provided
  dynamic "action" {
    for_each = each.value.log_analytics_workspace_id != null ? [1] : []
    content {
      type        = "Workspace"
      resource_id = each.value.log_analytics_workspace_id
    }
  }
}
