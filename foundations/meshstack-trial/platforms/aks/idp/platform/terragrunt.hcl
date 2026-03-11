include "common" {
  path = find_in_parent_folders("common.hcl")
}

include "azure" {
  path   = find_in_parent_folders("azure.hcl")
  expose = true
}

dependency "infra" {
  config_path = "../infra"
}

# The kubernetes, azurerm and azuread providers are configured here so both the root module
# (meshstack_platform) and the child backplane module inherit the same providers without extra wiring.
generate "provider" {
  path      = "provider.tf"
  if_exists = "overwrite"
  contents  = <<EOF
provider "kubernetes" {
  host                   = "${dependency.infra.outputs.kube_host}"
  cluster_ca_certificate = base64decode("${dependency.infra.outputs.cluster_ca_certificate}")
  client_certificate     = base64decode("${dependency.infra.outputs.client_certificate}")
  client_key             = base64decode("${dependency.infra.outputs.client_key}")
}

provider "azurerm" {
  features {}
}

provider "azuread" {}

provider "meshstack" {
  endpoint  = "https://api.try.meshstack.io"
  apikey    = "a17b9ad7-14c8-44cc-94ef-cb6b4db7ac8a"
  apisecret = "${get_env("MESHSTACK_API_SECRET_AKS_IDP")}"
}
EOF
}

inputs = {
  kube_host           = dependency.infra.outputs.kube_host
  aks_subscription_id = include.azure.locals.subscription_id
  aks_cluster_name    = dependency.infra.outputs.aks_cluster_name
  aks_resource_group  = dependency.infra.outputs.aks_resource_group
}
