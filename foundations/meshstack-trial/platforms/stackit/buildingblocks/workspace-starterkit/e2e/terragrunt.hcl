# Foundation-mode smoke test — see the `hub` skill (AGENTS.md) for the protocol.

include "smoke" {
  path   = find_in_parent_folders("smoke.hcl")
  expose = true
}

include "hub" {
  path   = "../hub.hcl"
  expose = true
}

terraform {
  source = "git::https://github.com/meshcloud/meshstack-hub.git//modules/${include.hub.locals.module}/e2e?ref=${include.hub.locals.git_ref}"

  # The no-TTL case only holds in hub mode: a published definition decides itself whether its TTL
  # is optional, so foundation mode always sends one.
  extra_arguments "skip_hub_only_cases" {
    commands = ["test"]
    arguments = [
      "-filter=tests/meshstack_workspace_starterkit.tftest.hcl",
      "-filter=tests/meshstack_workspace_starterkit_unit.tftest.hcl",
    ]
  }
}

generate "smoke_tfvars" {
  path              = "smoke.auto.tfvars.json"
  if_exists         = "overwrite"
  disable_signature = true
  contents = jsonencode({
    test_context = {
      mode = "foundation"
      # Not the smoke test's own workspace: the definition is a draft, which only its owning
      # workspace can order. This is also where the trial-starter orders it from.
      workspace   = "meshcloud"
      bbd_draft   = include.hub.locals.bbd_draft
      name_suffix = run_cmd("--terragrunt-quiet", "date", "-u", "+%Y%m%d%H%M%S")
      run_id      = "st${run_cmd("--terragrunt-quiet", "date", "-u", "+%y%m%d%H%M")}${run_cmd("--terragrunt-quiet", "sh", "-c", "LC_ALL=C tr -dc a-z0-9 </dev/urandom | head -c 3")}"

      # Becomes owner of each short-lived workspace and project a run creates.
      owner_username = "jrudolph@meshcloud.io"
      meshstack = {
        project_identifier_suffix = ""
      }
    }
  })
}
