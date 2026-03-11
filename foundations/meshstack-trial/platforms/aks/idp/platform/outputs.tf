output "owned_by_workspace" {
  description = "The meshstack workspace that owns the AKS platform resources"
  value       = data.meshstack_workspace.meshcloud.metadata.name
}

output "full_platform_identifier" {
  description = "The meshstack platform identifier for AKS namespaces"
  value       = "${meshstack_platform.aks.metadata.name}.${meshstack_platform.aks.spec.location_ref.name}"
}

output "landing_zone_dev_identifier" {
  description = "The meshstack landing zone identifier for AKS dev namespaces"
  value       = meshstack_landingzone.dev.metadata.name
}

output "landing_zone_prod_identifier" {
  description = "The meshstack landing zone identifier for AKS prod namespaces"
  value       = meshstack_landingzone.prod.metadata.name
}
