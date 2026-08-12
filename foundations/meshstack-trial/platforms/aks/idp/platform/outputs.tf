output "owned_by_workspace" {
  description = "The meshstack workspace that owns the AKS platform resources"
  value       = data.meshstack_workspace.meshcloud.metadata.name
}

output "platform_ref" {
  description = "Reference to the meshPlatform for AKS namespaces."
  value       = meshstack_platform.aks.ref
}

output "landing_zone_refs" {
  description = "References to the meshLandingZones, keyed by environment."
  value = {
    dev  = meshstack_landingzone.dev.ref
    prod = meshstack_landingzone.prod.ref
  }
}
