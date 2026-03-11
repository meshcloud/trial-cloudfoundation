include "common" {
  path = find_in_parent_folders("common.hcl")
}

include "azure" {
  path = find_in_parent_folders("azure.hcl")
}

dependency "infra" {
  config_path = "../../../infra"
}

generate "provider" {
  path      = "provider.tf"
  if_exists = "overwrite"
  contents  = <<EOF
provider "azurerm" {
  features {}
}

provider "azuread" {}

provider "kubernetes" {
  host                   = "${dependency.infra.outputs.kube_host}"
  cluster_ca_certificate = base64decode("${dependency.infra.outputs.cluster_ca_certificate}")
  client_certificate     = base64decode("${dependency.infra.outputs.client_certificate}")
  client_key             = base64decode("${dependency.infra.outputs.client_key}")
}
EOF
}

terraform {
  source = "git::https://github.com/meshcloud/meshstack-hub.git//modules/aks/github-connector/backplane?ref=feature/aks-starterkit-integration"
}

inputs = {
  resource_prefix = "bb-github-connector"

  aks = {
    cluster_name        = dependency.infra.outputs.aks_cluster_name
    resource_group_name = dependency.infra.outputs.aks_resource_group
  }

  acr = {
    location = "germanywestcentral"
  }
}
