# The hub module now mints this key in its backplane. Moving it there keeps the key and its secret,
# so the building block definition's credential inputs stay the same.
moved {
  from = meshstack_api_key.workspace_starterkit_admin
  to   = module.workspace_starterkit.module.backplane.meshstack_api_key.automation
}

locals {
  hub = {
    git_ref = "9c13aec4cc3f43b7f6cbc8051710414b3ca3c95a"
    # Vital: keeps this BBD in draft. A draft BBD is only orderable from its owning workspace
    # (meshcloud), never published to the marketplace — we want this hidden, not offered generally.
    bbd_draft = true
  }
}

module "workspace_starterkit" {
  source = "github.com/meshcloud/meshstack-hub//modules/meshstack/workspace-starterkit?ref=${local.hub.git_ref}"

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

  hub = local.hub

  # STACKIT University sandbox: every onboarded team gets a project+tenant here.
  platform_uuid     = "b66e3542-5887-4d48-9f06-968dbc98d97c"
  landing_zone_name = "stackit-sandbox-default"

  workspace_expiry_tag_key = "TrialEnd"

  # We deploy from developer machines, and rarely. A short lifetime would let the key expire between
  # applies, which stops every run of this building block.
  api_key_lifetime_days = 365
}
