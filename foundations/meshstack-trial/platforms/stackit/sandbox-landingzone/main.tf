terraform {
  required_version = ">= 1.12.0"

  required_providers {
    meshstack = {
      source  = "meshcloud/meshstack"
      version = ">= 0.22.0"
    }
  }
}

variable "stackit_service_account_key" {
  type      = string
  sensitive = true
}

data "meshstack_workspace" "owner" {
  metadata = {
    name = "meshcloud"
  }
}

module "stackit_sandbox_landingzone" {
  source = "github.com/meshcloud/meshstack-hub//reference-architectures/stackit-sandbox-landingzone?ref=e53005a3fab495fa433486469d9f792942b63be9"

  meshstack = {
    owning_workspace_identifier = data.meshstack_workspace.owner.metadata.name
  }

  hub = {
    git_ref   = "feature/stackit-project-custom-roles"
    bbd_draft = true
  }
}


resource "meshstack_building_block_v2" "stackit_sandbox_landingzone" {
  spec = {
    # Alternatively, use version_latest_release to target only released versions
    building_block_definition_version_ref = module.stackit_sandbox_landingzone.building_block_definition.version_ref

    display_name = "STACKIT Sandbox Landingzone"
    target_ref   = data.meshstack_workspace.owner.ref

    inputs = {
      platform_identifier         = { value_string = "stackit-sandbox" }
      tags                        = { value_code = jsonencode({ building_block = {}, landingzone = {} }) }
      stackit_org                 = { value_string = "05d7eb3f-f875-4bcd-ad0d-a07d62787f21" }
      stackit_owner_email         = { value_string = "stackit@meshcloud.io" }
      stackit_service_account_key = { value_code_sensitive = var.stackit_service_account_key }
      use_global_location         = { value_bool = true }
    }
  }
}
