terraform {
  required_version = ">= 1.12.0"

  required_providers {
    meshstack = {
      source  = "meshcloud/meshstack"
      version = ">= 0.23.1"
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
  source = "github.com/meshcloud/meshstack-hub//reference-architectures/stackit-sandbox-landingzone?ref=main"

  meshstack = {
    owning_workspace_identifier = data.meshstack_workspace.owner.metadata.name
  }

  hub = {
    git_ref   = "main"
    bbd_draft = true
  }
}


resource "meshstack_building_block" "stackit_sandbox_landingzone" {
  spec = {
    building_block_definition_version_ref = module.stackit_sandbox_landingzone.building_block_definition.version_ref

    display_name = "STACKIT Sandbox Landingzone"
    target_ref   = data.meshstack_workspace.owner.ref

    inputs = {
      platform_identifier = { value = jsonencode("stackit-sandbox") }
      tags = { value = jsonencode(jsonencode({
        building_block = { Company = ["stackit-university"] },
        landingzone    = { Company = ["stackit-university"] }
        }))
      }
      stackit_org         = { value = jsonencode("05d7eb3f-f875-4bcd-ad0d-a07d62787f21") }
      stackit_owner_email = { value = jsonencode("stackit@meshcloud.io") }
      stackit_service_account_key = { sensitive = {
        secret_value   = var.stackit_service_account_key
        secret_version = nonsensitive(sha256(var.stackit_service_account_key))
      } }
      use_global_location = { value = jsonencode(true) }
    }
  }
}

moved {
  from = meshstack_building_block_v2.stackit_sandbox_landingzone
  to   = meshstack_building_block.stackit_sandbox_landingzone
}
