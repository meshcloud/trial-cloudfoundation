# The hub module now mints this key in its backplane. Moving it there keeps the key and its secret,
# so the building block definition's credential inputs stay the same.
moved {
  from = meshstack_api_key.workspace_starterkit_admin
  to   = module.workspace_starterkit.module.backplane.meshstack_api_key.automation
}

variable "hub" {
  type = object({
    git_ref   = string
    bbd_draft = bool
  })
}

# Registered by the STACKIT sandbox landing zone in ../../sandbox-landingzone.
data "meshstack_building_block_definition" "stackit_project" {
  metadata = { uuid = "0e4ebeb3-b893-446a-b52a-3ab0c8294d71" }
}

module "workspace_starterkit" {
  source = "github.com/meshcloud/meshstack-hub//modules/meshstack/workspace-starterkit?ref=${var.hub.git_ref}"

  meshstack = {
    owning_workspace_identifier = "meshcloud"
    tags = {
      # Required: meshStack's "Restrict BuildingBlockDefinitions by Company" policy
      # requires this BBD's Company tag to intersect with its owning workspace's (meshcloud's)
      # Company=stackit-university tag, or creating the BBD fails outright. This is unrelated to
      # ordering visibility, which bbd_draft above is what actually controls (kept hidden).
      building_block = { Company = ["stackit-university"] }
      # The STACKIT Sandbox landing zone is itself tagged Company=stackit-university and enforces
      # a "Restrict LandingZones by Company" policy: any workspace placing a tenant there must share
      # that tag. Every workspace this building block creates needs it to be able to order a tenant
      # on that landing zone.
      workspace      = { Company = ["stackit-university"] }
      payment_method = {}
      project        = {}
    }
  }

  hub = var.hub

  # STACKIT University sandbox: every onboarded team gets a project+tenant here.
  platform_uuid     = "b66e3542-5887-4d48-9f06-968dbc98d97c"
  landing_zone_name = "stackit-sandbox-default"

  # The landing zone's own definitions stay drafts, so the workspaces this creates order the release.
  tenant_building_block = {
    definition_ref         = data.meshstack_building_block_definition.stackit_project.ref
    definition_version_ref = data.meshstack_building_block_definition.stackit_project.version_latest_release
    display_name           = "STACKIT Project"
  }

  workspace_expiry_tag_key = "TrialEnd"

  # We deploy from developer machines, and rarely. A short lifetime would let the key expire between
  # applies, which stops every run of this building block.
  api_key_lifetime_days = 365
}
