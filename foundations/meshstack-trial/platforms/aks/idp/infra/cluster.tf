module "aks" {
  source = "github.com/meshcloud/meshstack-hub//modules/azure/aks/buildingblock"

  resource_group_name = "starterkit"
  location            = "germanywestcentral"
  aks_cluster_name    = "aks-starterkit"
  dns_prefix          = "try-meshstack"

  node_count          = 1
  enable_auto_scaling = true
  min_node_count      = 1
  max_node_count      = 3

  vm_size = "standard_b2s_v2"

  # temporary aks-admins group created manually. Should probably reference a dependency on azure
  # platform that creates this group and outputs the object id.
  aks_admin_group_object_id = "472f9aeb-403d-4a0e-8294-ed2b8ca934e3"

  tags = {
    Environment = "production"

  }

  providers = {
    azurerm.hub = azurerm.hub
  }
}

# Read admin credentials back from the cluster. kube_config_raw uses exec/AAD auth when
# aks_admin_group_object_id is set, so we use kube_admin_config which always carries
# certificate-based local-admin credentials (requires local accounts to be enabled, which is the default).
data "azurerm_kubernetes_cluster" "aks" {
  name                = "aks-starterkit"
  resource_group_name = "starterkit"

  depends_on = [module.aks]
}

output "kube_config" {
  description = "Kubeconfig for the AKS cluster"
  value       = module.aks.kube_config
  sensitive   = true
}

output "kube_host" {
  description = "Kubernetes API server URL"
  value       = data.azurerm_kubernetes_cluster.aks.kube_admin_config[0].host
  sensitive   = true
}

output "cluster_ca_certificate" {
  description = "Base64-encoded cluster CA certificate"
  value       = data.azurerm_kubernetes_cluster.aks.kube_admin_config[0].cluster_ca_certificate
  sensitive   = true
}

output "client_certificate" {
  description = "Base64-encoded client certificate"
  value       = data.azurerm_kubernetes_cluster.aks.kube_admin_config[0].client_certificate
  sensitive   = true
}

output "client_key" {
  description = "Base64-encoded client key"
  value       = data.azurerm_kubernetes_cluster.aks.kube_admin_config[0].client_key
  sensitive   = true
}

output "oidc_issuer_url" {
  description = "OIDC issuer URL for workload identity"
  value       = module.aks.oidc_issuer_url
}

output "aks_identity_client_id" {
  description = "Client ID of the AKS managed identity"
  value       = module.aks.aks_identity_client_id
}

output "subnet_id" {
  description = "Subnet ID used by AKS"
  value       = module.aks.subnet_id
}

output "aks_cluster_name" {
  description = "Name of the AKS cluster"
  value       = data.azurerm_kubernetes_cluster.aks.name
}

output "aks_resource_group" {
  description = "Resource group containing the AKS cluster"
  value       = data.azurerm_kubernetes_cluster.aks.resource_group_name
}
