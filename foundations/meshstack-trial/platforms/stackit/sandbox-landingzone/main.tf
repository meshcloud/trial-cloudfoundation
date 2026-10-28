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
  git_ref = "eab6b8139c61bb12bdac3a189c19c968bbb8f1bd"
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

  # Set in meshPanel before this unit managed them; leaving them out would turn them off.
  approval_policies = {
    any_input_changes  = true
    manual_triggers    = true
    user_input_changes = true
    version_upgrade    = true
  }

  # Trial users work on this platform, so it keeps the plain identifier `stackit-sandbox`.
  playground_mode = false
}


resource "meshstack_building_block" "stackit_sandbox_landingzone" {
  spec = {
    building_block_definition_version_ref = module.stackit_sandbox_landingzone.building_block_definition.version_ref

    display_name = "STACKIT Sandbox Landingzone Architecture"
    target_ref   = data.meshstack_workspace.owner.ref

    inputs = {
      platform_identifier = { value = jsonencode("stackit-sandbox") }
      tags = { value = jsonencode(jsonencode({
        building_block        = [{ key = "Company", values = ["stackit-university"] }]
        landingzone           = [{ key = "Company", values = ["stackit-university"] }]
        project               = []
        project_owner_tag_key = ""
      })) }
      # This is an open landing zone: project admins get `owner` so real people can use STACKIT
      # freely, including granting access and escalating privileges through service accounts.
      role_mapping = { value = jsonencode(jsonencode({
        admin  = ["owner"]
        user   = ["editor"]
        reader = ["reader"]
      })) }
      stackit_org                 = { value = jsonencode(local.stackit_org) }
      stackit_owner_email         = { value = jsonencode(local.stackit_owner_email) }
      stackit_service_account_key = { sensitive = provider::meshstack::non_ephemeral_secret(nonsensitive(var.stackit_service_account_key)) }
      use_global_location         = { value = jsonencode(true) }

      stackit_organization_onboarding_enabled = { value = jsonencode(true) }
      topology                                = { value = jsonencode(["sandbox"]) }
    }
  }
}
