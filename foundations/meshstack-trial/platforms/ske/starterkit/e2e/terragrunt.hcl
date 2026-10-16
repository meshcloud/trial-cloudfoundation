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
      mode                 = "foundation"
      workspace            = include.smoke.locals.meshstack.workspace
      definition_workspace = "meshcloud"
      # A draft is only orderable from its owning workspace, and the smoke test runs in its own.
      bbd_draft   = false
      name_suffix = include.smoke_run.locals.name_suffix
      run_id      = include.smoke_run.locals.run_id
    }
  })
}
