# Owns every resource the workspace-starterkit building block creates or deletes on the
# admin-scoped provider it authenticates with (see modules/meshstack/workspace-starterkit).
# Created here instead of injected from the environment so no admin credential needs to be
# provisioned or rotated by hand.
resource "meshstack_api_key" "workspace_starterkit_admin" {
  metadata = {
    owned_by_workspace = "meshcloud"
  }

  spec = {
    display_name = "workspace-starterkit-admin"
    permissions = [
      "ADM_WORKSPACE_SAVE", "ADM_WORKSPACE_LIST", "ADM_WORKSPACE_DELETE",
      "ADM_PAYMENTMETHOD_SAVE", "ADM_PAYMENTMETHOD_LIST", "ADM_PAYMENTMETHOD_DELETE",
      "ADM_PROJECT_SAVE", "ADM_PROJECT_LIST", "ADM_PROJECT_DELETE",
      "ADM_TENANT_SAVE", "ADM_TENANT_LIST", "ADM_TENANT_DELETE",
      "ADM_WORKSPACEPRINCIPALBINDING_SAVE", "ADM_WORKSPACEPRINCIPALBINDING_LIST", "ADM_WORKSPACEPRINCIPALBINDING_DELETE",
      "ADM_PROJECTPRINCIPALROLE_SAVE", "ADM_PROJECTPRINCIPALROLE_LIST", "ADM_PROJECTPRINCIPALROLE_DELETE",
    ]
  }
}

locals {
  hub = {
    git_ref = "e7ce957b33283b257e073d6b81f0e95d0f5fd546"
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

  meshstack_admin_api_key    = meshstack_api_key.workspace_starterkit_admin.status.client_id
  meshstack_admin_api_secret = meshstack_api_key.workspace_starterkit_admin.status.client_secret

  workspace_expiry_tag_key = "TrialEnd"
}
