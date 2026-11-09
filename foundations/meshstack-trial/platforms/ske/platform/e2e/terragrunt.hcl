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
  source = "git::https://github.com/meshcloud/meshstack-hub.git//modules/ske/ske-starterkit/e2e?ref=${include.hub.locals.git_ref}"
}

generate "smoke_tfvars" {
  path              = "smoke.auto.tfvars.json"
  if_exists         = "overwrite"
  disable_signature = true
  contents = jsonencode({
    test_context = {
      mode      = "foundation"
      workspace = include.smoke.locals.meshstack.workspace
      # The platform building block lives in meshcloud, and its definitions with it.
      definition_workspace      = "meshcloud"
      bbd_draft                 = false
      run_id                    = include.smoke_run.locals.run_id
      payment_method_identifier = include.smoke.locals.meshstack.payment_method
    }
  })
}
