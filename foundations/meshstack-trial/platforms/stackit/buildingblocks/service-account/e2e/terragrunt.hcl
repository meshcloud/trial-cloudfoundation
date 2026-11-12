# Foundation-mode smoke test — see the `hub` skill (AGENTS.md) for the protocol.

include "smoke" {
  path   = find_in_parent_folders("smoke.hcl")
  expose = true
}

include "smoke_run" {
  path   = find_in_parent_folders("smoke_run.hcl")
  expose = true
}

include "hub" {
  path   = "../hub.hcl"
  expose = true
}

terraform {
  source = "git::https://github.com/meshcloud/meshstack-hub.git//modules/${include.hub.locals.module}/e2e?ref=${include.hub.locals.git_ref}"
}

generate "smoke_tfvars" {
  path              = "smoke.auto.tfvars.json"
  if_exists         = "overwrite"
  disable_signature = true
  contents = jsonencode({
    test_context = {
      mode = "foundation"
      # The federation and its probe definition must belong to the workspace that owns the tenant.
      workspace            = include.smoke.locals.stackit.workspace
      definition_workspace = "meshcloud"
      bbd_draft            = include.hub.locals.bbd_draft
      # The probe definition runs code from this hub commit.
      hub_git_ref = include.hub.locals.git_ref
      name_suffix = include.smoke_run.locals.name_suffix
      run_id      = include.smoke_run.locals.run_id

      fixtures = {
        stackit = {
          mesh_tenant_id = include.smoke.locals.stackit.mesh_tenant_id
        }
      }
    }
  })
}
