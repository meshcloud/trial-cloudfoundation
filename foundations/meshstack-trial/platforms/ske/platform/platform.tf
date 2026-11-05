locals {
  version_upgrade_gate = {
    building_block_creation = false
    user_input_changes      = false
    any_input_changes       = false
    manual_triggers         = false
    version_upgrade         = true
  }

  # Trial namespaces get no storage.
  stage_quotas = {
    dev = [
      { key = "limits.cpu", value = 500 },
      { key = "requests.cpu", value = 250 },
      { key = "limits.memory", value = 256 },
      { key = "requests.memory", value = 256 },
      { key = "requests.storage", value = 0 },
      { key = "persistentvolumeclaims", value = 0 },
    ]
    prod = [
      { key = "limits.cpu", value = 500 },
      { key = "requests.cpu", value = 500 },
      { key = "limits.memory", value = 512 },
      { key = "requests.memory", value = 512 },
      { key = "requests.storage", value = 0 },
      { key = "persistentvolumeclaims", value = 0 },
    ]
  }

  quota_definitions = [
    {
      quota_key               = "limits.cpu"
      label                   = "CPU limit"
      description             = "The sum of CPU limits across all pods in a non-terminal state cannot exceed this value."
      unit                    = "m"
      min_value               = 0
      max_value               = 500
      auto_approval_threshold = 500
    },
    {
      quota_key               = "requests.cpu"
      label                   = "CPU requests"
      description             = "The sum of CPU requests across all pods in a non-terminal state cannot exceed this value."
      unit                    = "m"
      min_value               = 0
      max_value               = 500
      auto_approval_threshold = 500
    },
    {
      quota_key               = "limits.memory"
      label                   = "Memory limit"
      description             = "The sum of memory limits across all pods in a non-terminal state cannot exceed this value."
      unit                    = "Mi"
      min_value               = 0
      max_value               = 512
      auto_approval_threshold = 512
    },
    {
      quota_key               = "requests.memory"
      label                   = "Memory requests"
      description             = "The sum of memory requests across all pods in a non-terminal state cannot exceed this value."
      unit                    = "Mi"
      min_value               = 0
      max_value               = 512
      auto_approval_threshold = 512
    },
    {
      quota_key               = "requests.storage"
      label                   = "Total Storage Requests"
      description             = "Across all persistent volume claims, the sum of storage requests cannot exceed this value."
      unit                    = "Gi"
      min_value               = 0
      max_value               = 0
      auto_approval_threshold = 0
    },
    {
      quota_key               = "persistentvolumeclaims"
      label                   = "Persistent Volume Claims"
      description             = "The total number of PersistentVolumeClaims that can exist in the namespace."
      unit                    = ""
      min_value               = 0
      max_value               = 0
      auto_approval_threshold = 0
    },
  ]
}

module "stackit_kubernetes" {
  source = "git::https://github.com/meshcloud/meshstack-hub.git//reference-architectures/stackit-kubernetes?ref=${var.hub_ref}"

  meshstack = {
    owning_workspace_identifier = local.owning_workspace_identifier
    # The policy "Restrict BuildingBlockDefinitions by Company" refuses orders in meshcloud of an untagged definition.
    tags = { Company = ["stackit-university"] }
  }
  hub = {
    git_ref   = var.hub_ref
    bbd_draft = false
  }

  approval_policies = local.version_upgrade_gate
}

resource "meshstack_building_block" "platform" {
  wait_for_completion = true

  lifecycle {
    postcondition {
      condition     = self.status.succeeded
      error_message = "Building block ${self.metadata.uuid} did not succeed: health status ${self.status.health_status}, action ${self.status.action}. See its run in meshPanel."
    }
  }

  spec = {
    building_block_definition_version_ref = module.stackit_kubernetes.building_block_definition.version_ref

    display_name = "STACKIT Kubernetes Platform"
    target_ref = {
      kind = "meshWorkspace"
      name = local.owning_workspace_identifier
    }

    # A replaced tenant deletes the STACKIT project through its "STACKIT Project" building block.
    inputs = {
      landingzone = { value = jsonencode(jsonencode({
        platform_ref = { uuid = local.stackit_platform_uuid }
        landingzone_refs = {
          default = { name = "stackit-sandbox-default" }
        }
        service_account_bbd_version_ref            = data.meshstack_building_block_definition.service_account.version_latest
        service_account_federation_bbd_version_ref = data.meshstack_building_block_definition.service_account_federation.version_latest
      })) }
      landingzone_variant = { value = jsonencode("default") }
      platform_identifier = { value = jsonencode("try-meshstack") }
      playground_mode     = { value = jsonencode(false) }
      # The legacy starterkit created its projects with a suffix.
      starterkit_add_random_name_suffix = { value = jsonencode(true) }
      use_global_location               = { value = jsonencode(true) }
      payment_method                    = { value = jsonencode({ kind = "meshPaymentMethod", name = "meshcloud-budget" }) }
      dns_domain                        = { value = jsonencode("stackit.run") }
      phase2_completed                  = { value = jsonencode(true) }

      starterkit_demo = { value = jsonencode(jsonencode({
        name          = "ai-summarizer"
        template_repo = "https://github.com/likvid-bank/starterkit-template-stackit-ai-summarizer.git"
        ai_model      = "openai/gpt-oss-120b"
      })) }
      overrides = { value = jsonencode(jsonencode({
        project_identifier   = "stackit-kubernetes-platform"
        cluster_name         = "try-mesh"
        cluster_issuer_email = "ske@meshcloud.io"
      })) }
      quota_definitions = { value = jsonencode(jsonencode(local.quota_definitions)) }

      tags = { value = jsonencode(jsonencode({
        project                   = []
        starterkit_project        = []
        landingzone               = []
        building_block            = []
        starterkit_building_block = []
      })) }
      stages = { value = jsonencode(jsonencode([
        for stage, quotas in local.stage_quotas : { name = stage, landingzone = [], project = [], quotas = quotas }
      ])) }

      approval_policies = { value = jsonencode(jsonencode(local.version_upgrade_gate)) }
      # Application teams move to the new starterkit version only through a reviewed upgrade.
      starterkit_approval_policies = { value = jsonencode(jsonencode(local.version_upgrade_gate)) }

      imports = { value = jsonencode(jsonencode({
        project = {
          display_name   = "STACKIT Kubernetes Platform"
          admin_bindings = {}
        }
        adopt_ske = true
        git = {
          instance_id          = "bddcefe5-004c-4a7a-b40e-decc66d3649c"
          instance_name        = "try-meshstack"
          forgejo_organization = "try-meshstack"
        }
        dns = {
          zone_id       = "25c3c750-caa8-4d6b-a6a4-54f0e1102747"
          record_set_id = "83e11514-c7d8-4080-af18-c97bb7785d99"
        }
        adopt_ingress = true
        kubernetes_platform = {
          platform_name = "ske-namespace"
          location_name = "global"
          landingzone_names = {
            dev  = "ske-namespace-dev"
            prod = "ske-namespace-prod"
          }
        }
        starterkit_definitions = {
          starterkit        = "3a6c8b17-e9d0-468e-ab2d-d934d040116c"
          git_repository    = "74832579-a5f8-4fb8-986b-66f314d00ccd"
          forgejo_connector = "7d2f9d36-6970-451d-9462-3938b50ba4df"
        }
      })) }
      # Empty since the Forgejo organization is adopted; leaving the input out would keep the stored token.
      import_secrets = {
        sensitive = {
          secret_value   = jsonencode({})
          secret_version = sha256(jsonencode({}))
        }
      }
    }
  }
}
