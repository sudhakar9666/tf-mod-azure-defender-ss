#--------------------------------------------------------------
# Defender Plans — Subscription-Level
#--------------------------------------------------------------
variable "defender_plans" {
  description = <<-EOT
    List of Defender for Cloud plans to enable at the subscription level.
    Supported resource types:
    - VirtualMachines         (Servers)
    - AppServices             (App Service)
    - SqlServers              (Azure SQL Databases)
    - SqlServerVirtualMachines (SQL Servers on machines)
    - OpenSourceRelationalDatabases (Open-source relational databases)
    - Containers              (Containers)
    - ContainerRegistry       (Container Registry)
    - KubernetesService       (Kubernetes / AKS)
    - Arm                     (Resource Manager)
    - Api                     (APIs)
    - AI                      (Azure AI Services)
    - Dns                     (DNS)
    - CloudPosture            (Cloud Security Posture Management / CSPM)

    Each plan accepts:
    - resource_type: One of the supported types above
    - tier: "Standard" or "Free" (default: "Standard")
    - subplan: Optional subplan (e.g., "P1", "P2", "DefenderForStorageV2", "PerKeyVault", "PerSubscription")
    - extensions: Optional list of extensions
  EOT
  type = list(object({
    resource_type = string
    tier          = optional(string, "Standard")
    subplan       = optional(string, null)
    extensions = optional(list(object({
      name                            = string
      additional_extension_properties = optional(map(string), null)
    })), null)
  }))
  default  = []
  nullable = false

  validation {
    condition = alltrue([
      for plan in var.defender_plans : contains([
        "VirtualMachines",
        "AppServices",
        "SqlServers",
        "SqlServerVirtualMachines",
        "OpenSourceRelationalDatabases",
        "Containers",
        "ContainerRegistry",
        "KubernetesService",
        "Arm",
        "Api",
        "AI",
        "Dns",
        "CloudPosture",
      ], plan.resource_type)
    ])
    error_message = "Only the following resource_type values are supported: VirtualMachines, AppServices, SqlServers, SqlServerVirtualMachines, OpenSourceRelationalDatabases, Containers, ContainerRegistry, KubernetesService, Arm, Api, AI, Dns, CloudPosture."
  }
}

#--------------------------------------------------------------
# Security Contact
#--------------------------------------------------------------
variable "security_contact" {
  description = "Security contact information for Defender for Cloud alerts. Set to null to skip."
  type = object({
    name  = optional(string, null)
    email = string
    phone = optional(string, null)
  })
  default = null
}

variable "alert_notifications_enabled" {
  description = "Whether to send security alert notifications to the security contact."
  type        = bool
  default     = true
}

variable "alerts_to_admins_enabled" {
  description = "Whether to send security alert notifications to subscription admins (Owners)."
  type        = bool
  default     = true
}

#--------------------------------------------------------------
# Security Center Settings
#--------------------------------------------------------------
variable "security_center_settings" {
  description = <<-EOT
    Map of security center settings to enable/disable.
    Supported keys:
    - "WDATP" — Microsoft Defender for Endpoint (enables built-in VA for Servers)
    - "MCAS" — Microsoft Defender for Cloud Apps
    - "Sentinel" — Microsoft Sentinel integration
  EOT
  type        = map(bool)
  default     = {}
}

#--------------------------------------------------------------
# MCSB Policy Assignment
#--------------------------------------------------------------
variable "enable_mcsb_assignment" {
  description = "Whether to assign the Microsoft Cloud Security Benchmark (MCSB) policy initiative to the subscription."
  type        = bool
  default     = false
}

variable "mcsb_assignment_name" {
  description = "The name for the MCSB policy assignment resource."
  type        = string
  default     = "mcsb"
}

#--------------------------------------------------------------
# Log Analytics Workspace
#--------------------------------------------------------------
variable "log_analytics_workspace_id" {
  description = "The full resource ID of the Log Analytics workspace for Defender for Cloud data. Set to null to skip."
  type        = string
  default     = null
}

#--------------------------------------------------------------
# Defender for Storage — Per-Resource
#--------------------------------------------------------------
variable "storage_accounts" {
  description = <<-EOT
    List of existing Storage Accounts where Microsoft Defender for Storage
    should be enabled.

    The module automatically looks up each Storage Account and applies the
    standard Defender for Storage configuration.

    Leave the list empty to skip Defender for Storage configuration.
  EOT

  type = list(object({
    name                = string
    resource_group_name = string
  }))

  default  = []
  nullable = false
}

#--------------------------------------------------------------
# Defender for Cosmos DB — Existing Cosmos DB Accounts
#--------------------------------------------------------------
variable "cosmosdb_accounts" {
  description = <<-EOT
    List of existing Cosmos DB Accounts where Microsoft Defender should be enabled.

    The module automatically looks up each Cosmos DB Account and enables
    Microsoft Defender.

    Leave the list empty to skip Cosmos DB configuration.
  EOT

  type = list(object({
    name                = string
    resource_group_name = string
  }))

  default  = []
  nullable = false
}
#--------------------------------------------------------------
# Defender for Key Vault — Existing Key Vaults
#--------------------------------------------------------------
variable "key_vaults" {
  description = <<-EOT
    List of existing Key Vaults where Microsoft Defender should be enabled.

    The module automatically looks up each Key Vault and enables
    Microsoft Defender.

    Leave the list empty to skip Key Vault configuration.
  EOT

  type = list(object({
    name                = string
    resource_group_name = string
  }))

  default  = []
  nullable = false
}
#--------------------------------------------------------------

#--------------------------------------------------------------
# Security Center Automation Rules (Workflow Automation & Continuous Export)
#--------------------------------------------------------------
variable "automation_rules" {
  description = <<-EOT
    List of Security Center automation rules for workflow automation and continuous export.
    Automation rules can export findings to Event Hubs and Log Analytics workspaces.

    Arguments:
    - name: Name of the automation rule (must be unique within subscription)
    - enabled: Whether the rule is enabled (default: true)
    - description: Optional description of the rule
    - scopes: Optional list of scopes (defaults to current subscription)
    - event_hubs_resource_id: Optional Event Hub resource ID for exporting findings
    - log_analytics_workspace_id: Optional Log Analytics workspace ID for exporting findings
  EOT
  type = list(object({
    name                       = string
    enabled                    = optional(bool, true)
    description                = optional(string, null)
    scopes                     = optional(list(string), null)
    event_hubs_resource_id     = optional(string, null)
    log_analytics_workspace_id = optional(string, null)
  }))
  default  = []
  nullable = false
}


#--------------------------------------------------------------
# Defender for Cloud Automation
#--------------------------------------------------------------
variable "automation_resource_group_name" {
  description = "Resource Group where Microsoft Defender for Cloud Automation resources will be deployed."

  type    = string
  default = null
}