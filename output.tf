#--------------------------------------------------------------
# Subscription-Level Outputs
#--------------------------------------------------------------
output "defender_plans" {
  description = "Map of enabled Defender for Cloud plans with their resource IDs."
  value = {
    for k, v in azurerm_security_center_subscription_pricing.plans : k => {
      id            = v.id
      resource_type = v.resource_type
      tier          = v.tier
      subplan       = v.subplan
    }
  }
}

output "security_contact_id" {
  description = "The ID of the security center contact resource."
  value       = length(azurerm_security_center_contact.security_contact) > 0 ? azurerm_security_center_contact.security_contact[0].id : null
}

output "mcsb_assignment_id" {
  description = "The ID of the MCSB policy assignment."
  value       = length(azurerm_subscription_policy_assignment.mcsb) > 0 ? azurerm_subscription_policy_assignment.mcsb[0].id : null
}

output "subscription_id" {
  description = "The subscription ID where Defender for Cloud is configured."
  value       = data.azurerm_subscription.current.subscription_id
}

#--------------------------------------------------------------
# Per-Resource Outputs
#--------------------------------------------------------------
output "storage_defender_ids" {
  description = "Map of Storage Account names to Defender for Storage resource IDs."

  value = {
    for k, v in azurerm_security_center_storage_defender.storage_defender : k => v.id
  }
}
output "key_vault_defender_ids" {
  description = "Map of Key Vault names to Defender resource IDs."

  value = {
    for k, v in azurerm_advanced_threat_protection.key_vault_defender : k => v.id
  }
}

output "cosmosdb_defender_ids" {
  description = "Map of Cosmos DB account names to Defender resource IDs."

  value = {
    for k, v in azurerm_advanced_threat_protection.cosmosdb_defender : k => v.id
  }
}

#--------------------------------------------------------------
# Automation Rules Outputs
#--------------------------------------------------------------
output "automation_rule_ids" {
  description = "Map of automation rule names to their resource IDs."
  value = {
    for k, v in azurerm_security_center_automation.automation_rules : k => v.id
  }
}
