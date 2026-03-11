terraform {
  required_providers {
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 3.0.1"
    }
    meshstack = {
      source  = "meshcloud/meshstack"
      version = "~> 0.19.1"
    }
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.0"
    }
    azuread = {
      source  = "hashicorp/azuread"
      version = "~> 3.0"
    }
  }
}

variable "kube_host" {
  description = "Kubernetes API server URL"
  type        = string
}

variable "aks_subscription_id" {
  description = "Azure subscription ID where the AKS cluster resides"
  type        = string
}

variable "aks_cluster_name" {
  description = "Name of the AKS cluster"
  type        = string
}

variable "aks_resource_group" {
  description = "Resource group containing the AKS cluster"
  type        = string
}

# For workload identity federation config
data "meshstack_integrations" "integrations" {}

# For Entra tenant name
data "azuread_domains" "aad_domains" {
  only_initial = true
}

data "meshstack_workspace" "meshcloud" {
  metadata = {
    name = "meshcloud"
  }
}

module "backplane" {
  source = "./backplane"

  subscription_id = var.aks_subscription_id
  wif_issuer      = data.meshstack_integrations.integrations.workload_identity_federation.replicator.issuer
  wif_subject     = data.meshstack_integrations.integrations.workload_identity_federation.replicator.subject
}

resource "meshstack_platform" "aks" {
  metadata = {
    name               = "aks-namespace"
    owned_by_workspace = data.meshstack_workspace.meshcloud.metadata.name
  }

  spec = {
    display_name      = "AKS Namespace"
    description       = "Azure Kubernetes Service (AKS). Create a k8s namespace in our AKS cluster."
    endpoint          = var.kube_host
    documentation_url = ""
    support_url       = ""

    location_ref = {
      name = "global"
    }

    availability = {
      publication_state        = "PUBLISHED"
      restriction              = "PUBLIC"
      restricted_to_workspaces = []
    }

    contributing_workspaces = []

    config = {
      aks = {
        base_url               = var.kube_host
        disable_ssl_validation = true

        replication = {

          service_principal = {
            entra_tenant = data.azuread_domains.aad_domains.domains[0].domain_name
            client_id    = module.backplane.replicator_service_principal.Application_Client_ID
            object_id    = module.backplane.replicator_service_principal.Enterprise_Application_Object_ID

            # No credential -> use workload identity federation
            auth = {
              credential = null
            }
          }

          # Direct k8s access does not use workload identity federation
          access_token = {
            secret_value = module.backplane.replicator_token
            # # Use this to detect secret changes.
            # secret_version = sha256(module.backplane.replicator_token)
          }

          group_name_pattern     = "aks-#{workspaceIdentifier}.#{projectIdentifier}-#{platformGroupAlias}"
          namespace_name_pattern = "#{workspaceIdentifier}-#{projectIdentifier}"

          user_lookup_strategy       = "UserByMailLookupStrategy"
          send_azure_invitation_mail = false

          aks_subscription_id = var.aks_subscription_id
          aks_cluster_name    = var.aks_cluster_name
          aks_resource_group  = var.aks_resource_group
        }

        metering = {
          client_config = {
            access_token = {
              secret_value   = module.backplane.metering_token
              # secret_version = sha256(module.backplane.metering_token)
            }
          }
          processing = {}
        }
      }
    }

    # Cluster sizing: 2 vCPU + 8 Gi RAM per node, 1 node default / 3 node max.
    # Expected density: 20-30 illustration namespaces across the cluster.
    # CPU in millicores (m), memory in mebibytes (Mi) so values stay whole integers.
    quota_definitions = [
      {
        quota_key               = "limits.cpu"
        label                   = "CPU limit"
        description             = "The sum of CPU limits across all pods in a non-terminal state cannot exceed this value."
        unit                    = "m"
        min_value               = 0
        max_value               = 1000 # 1 vCPU per namespace
        auto_approval_threshold = 1000
      },
      {
        quota_key               = "requests.cpu"
        label                   = "CPU requests"
        description             = "The sum of CPU requests across all pods in a non-terminal state cannot exceed this value."
        unit                    = "m"
        min_value               = 0
        max_value               = 1000
        auto_approval_threshold = 500
      },
      {
        quota_key               = "limits.memory"
        label                   = "Memory limit"
        description             = "The sum of memory limits across all pods in a non-terminal state cannot exceed this value."
        unit                    = "Mi"
        min_value               = 0
        max_value               = 1024 # 1 Gi per namespace
        auto_approval_threshold = 1024
      },
      {
        quota_key               = "requests.memory"
        label                   = "Memory requests"
        description             = "The sum of memory requests across all pods in a non-terminal state cannot exceed this value."
        unit                    = "Mi"
        min_value               = 0
        max_value               = 1024
        auto_approval_threshold = 512
      },
      {
        quota_key               = "requests.storage"
        label                   = "Total Storage Requests"
        description             = "Across all persistent volume claims, the sum of storage requests cannot exceed this value."
        unit                    = "Gi"
        min_value               = 0
        max_value               = 5
        auto_approval_threshold = 2
      },
      {
        quota_key               = "persistentvolumeclaims"
        label                   = "Persistent Volume Claims"
        description             = "The total number of PersistentVolumeClaims that can exist in the namespace."
        unit                    = ""
        min_value               = 0
        max_value               = 4
        auto_approval_threshold = 2
      },
    ]
  }
}

resource "meshstack_landingzone" "dev" {
  metadata = {
    name               = "aks-namespace-dev"
    owned_by_workspace = data.meshstack_workspace.meshcloud.metadata.name
  }

  spec = {
    display_name                  = "AKS Namespace – Development"
    description                   = "Landing zone for development workloads."
    automate_deletion_approval    = true
    automate_deletion_replication = true

    platform_ref = {
      uuid = meshstack_platform.aks.metadata.uuid
    }

    platform_properties = {
      aks = {
        kubernetes_role_mappings = [
          {
            project_role_ref = { name = "admin" }
            platform_roles   = ["admin"]
          },
          {
            project_role_ref = { name = "user" }
            platform_roles   = ["edit"]
          },
          {
            project_role_ref = { name = "reader" }
            platform_roles   = ["view"]
          },
        ]
      }
    }

    quotas = [
      { key = "limits.cpu", value = 500 },
      { key = "requests.cpu", value = 250 },
      { key = "limits.memory", value = 512 },
      { key = "requests.memory", value = 256 },
      { key = "requests.storage", value = 1 },
      { key = "persistentvolumeclaims", value = 2 },
    ]
  }
}

resource "meshstack_landingzone" "prod" {
  metadata = {
    name               = "aks-namespace-prod"
    owned_by_workspace = data.meshstack_workspace.meshcloud.metadata.name
  }

  spec = {
    display_name                  = "AKS Namespace – Production"
    description                   = "Landing zone for production workloads."
    automate_deletion_approval    = true
    automate_deletion_replication = true

    platform_ref = {
      uuid = meshstack_platform.aks.metadata.uuid
    }

    platform_properties = {
      aks = {
        kubernetes_role_mappings = [
          {
            project_role_ref = { name = "admin" }
            platform_roles   = ["admin"]
          },
          {
            project_role_ref = { name = "user" }
            platform_roles   = ["edit"]
          },
          {
            project_role_ref = { name = "reader" }
            platform_roles   = ["view"]
          },
        ]
      }
    }

    quotas = [
      { key = "limits.cpu", value = 1000 },
      { key = "requests.cpu", value = 500 },
      { key = "limits.memory", value = 1024 },
      { key = "requests.memory", value = 512 },
      { key = "requests.storage", value = 2 },
      { key = "persistentvolumeclaims", value = 4 },
    ]
  }
}
