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
  git_ref = "942edaf0fdb24fe3dec0f4cf70dffd18740cc265"
}

module "stackit_sandbox_landingzone" {
  source = "github.com/meshcloud/meshstack-hub//reference-architectures/stackit-sandbox-landingzone?ref=${local.git_ref}"

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
      # Sandbox tenants are capped at `editor`, because `owner` additionally grants iam.member.add,
      # iam.role.add and the per-product role-binding permissions. Those would let a tenant give
      # STACKIT access to people meshStack does not know about, and meshStack would neither see nor
      # remove them: it only ever writes role assignments for its own project members.
      #
      # Known gap: this does not keep the project itself safe. `editor` carries
      # resource-manager.project.delete just as `owner` does, so a tenant can still delete the
      # project while the STACKIT Project building block goes on managing it in terraform. The block's
      # state then names a project that no longer exists, and its next run fails or recreates it.
      # Only `reader` lacks the permission, and `reader` is no use to someone meant to build here.
      #
      # Closing the gap needs a custom STACKIT role, because a built-in role cannot have a single
      # permission subtracted from it: `permissions` on stackit_authorization_*_custom_role is an
      # explicit list, and no data source reads a built-in role to generate one. That means carrying
      # `editor`'s other 808 permissions in this repo and refreshing them whenever STACKIT ships a
      # service, or trial users silently lose access to it. Accepted for now, because a tenant can
      # only delete its own sandbox.
      role_mapping = { value = jsonencode(jsonencode({
        admin  = ["editor"]
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
