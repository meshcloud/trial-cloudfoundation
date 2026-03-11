include "common" {
  path = find_in_parent_folders("common.hcl")
}

include "azure" {
  path = find_in_parent_folders("azure.hcl")
}

generate "provider" {
  path      = "provider.tf"
  if_exists = "overwrite"
  contents  = <<-EOF
  provider "azurerm" {
    features {}
  }

  provider "azurerm" {
    alias    = "hub"
    features {}
  }
  EOF
}

inputs = {
  resource_group_name = "starterkit"
  location            = "germanywestcentral"
  aks_cluster_name    = "aks-starterkit"
  dns_prefix          = "try-meshstack"
  node_count          = "2"
  vm_size             = "Standard_B2s"
}
