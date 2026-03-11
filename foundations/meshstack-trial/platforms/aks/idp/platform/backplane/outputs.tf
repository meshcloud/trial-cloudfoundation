output "replicator_token" {
  description = "Service account token for the meshStack replicator"
  value       = module.meshplatform.replicator_token
  sensitive   = true
}

output "metering_token" {
  description = "Service account token for the meshStack metering agent"
  value       = module.meshplatform.metering_token
  sensitive   = true
}

output "replicator_service_principal" {
  description = "Azure AD service principal for the meshStack replicator"
  value       = module.meshplatform.replicator_service_principal
  sensitive   = true
}
