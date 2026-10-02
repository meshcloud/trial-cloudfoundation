variable "stackit_service_account_key" {
  type      = string
  sensitive = true
}

locals {
  stackit_org         = "05d7eb3f-f875-4bcd-ad0d-a07d62787f21"
  stackit_owner_email = "stackit@meshcloud.io"
}

data "meshstack_workspace" "owner" {
  metadata = {
    name = "meshcloud"
  }
}

locals {
  git_ref = "f656771c31a38c548b7cef540dc97b6a8754e49e"
}

module "stackit_sandbox_landingzone" {
  # The hub merged the sandbox and hub-and-spoke architectures into one `stackit-landingzone` that
  # takes an optional `network`. Leaving `network` unset keeps this deployment sandbox-only.
  source = "github.com/meshcloud/meshstack-hub//reference-architectures/stackit-landingzone?ref=${local.git_ref}"

  meshstack = {
    owning_workspace_identifier = data.meshstack_workspace.owner.metadata.name
  }

  hub = {
    git_ref   = local.git_ref
    bbd_draft = true
  }
}


resource "meshstack_building_block" "stackit_sandbox_landingzone" {
  spec = {
    building_block_definition_version_ref = module.stackit_sandbox_landingzone.building_block_definition.version_ref

    display_name = "STACKIT Sandbox Landingzone Architecture"
    target_ref   = data.meshstack_workspace.owner.ref

    inputs = {
      platform_identifier = { value = jsonencode("stackit-sandbox") }
      tags = { value = jsonencode(jsonencode({
        building_block = { Company = ["stackit-university"] },
        landingzone    = { Company = ["stackit-university"] }
        }))
      }
      # This is an open landing zone: project admins get `owner` so real people can use STACKIT
      # freely, including granting access and escalating privileges through service accounts.
      role_mapping = { value = jsonencode(jsonencode({
        admin  = ["owner"]
        user   = ["editor"]
        reader = ["reader"]
      })) }
      stackit_org         = { value = jsonencode(local.stackit_org) }
      stackit_owner_email = { value = jsonencode(local.stackit_owner_email) }
      stackit_service_account_key = { sensitive = {
        secret_value   = var.stackit_service_account_key
        secret_version = nonsensitive(sha256(var.stackit_service_account_key))
      } }
      use_global_location = { value = jsonencode(true) }
    }
  }
}
