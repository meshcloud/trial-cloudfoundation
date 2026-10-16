locals {
  git_ref = "9c13aec4cc3f43b7f6cbc8051710414b3ca3c95a"
}

module "workspace_starterkit" {
  source = "github.com/meshcloud/meshstack-hub//modules/meshstack/workspace-starterkit?ref=${local.git_ref}"

  meshstack = {
    owning_workspace_identifier = "meshcloud"

    # The Company tag on the definition limits it to stackit-university workspaces. The tag on the
    # workspace it creates puts that workspace in the same audience.
    tags = {
      building_block = { Company = ["stackit-university"] }
      workspace      = { Company = ["stackit-university"] }
      payment_method = {}
      project        = {}
    }
  }

  # The sandbox landing zone building block (../../sandbox-landingzone) registers this platform and
  # landing zone. They come out of a building block run, not out of that unit's state.
  platform_uuid     = "b66e3542-5887-4d48-9f06-968dbc98d97c" # stackit-sandbox
  landing_zone_name = "stackit-sandbox-default"

  workspace_expiry_tag_key = "TrialEnd"

  # The trial-starter orders this definition from the owning workspace, which can use a draft.
  hub = { git_ref = local.git_ref, bbd_draft = true }
}

# Created by hand before this unit existed. Importing keeps its UUID, which the trial-starter uses.
import {
  to = module.workspace_starterkit.meshstack_building_block_definition.this
  id = "c69625fa-e9e8-47eb-aa02-e836c6431aaf"
}
