# Platform Backplane Module
#
# Creates the meshStack replicator and metering service accounts on the AKS cluster
# and the Azure AD service principal for workload identity federation.
# The kubernetes and azurerm providers are inherited from the calling root (platform/main.tf).

variable "subscription_id" {
  description = "Azure subscription ID where the AKS cluster resides"
  type        = string
}

variable "wif_issuer" {
  description = "Workload identity federation issuer URL from meshStack integrations"
  type        = string
}

variable "wif_subject" {
  description = "Workload identity federation subject from meshStack integrations"
  type        = string
}

module "meshplatform" {
  source  = "meshcloud/meshplatform/aks"
  version = "~> 0.2.0"

  namespace = "meshcloud"
  scope     = var.subscription_id

  replicator_enabled     = true
  service_principal_name = "replicator-service-principal"

  metering_enabled = true

  create_password = false # Use only workload identity federation
  workload_identity_federation = {
    issuer         = var.wif_issuer
    access_subject = var.wif_subject
  }
}
