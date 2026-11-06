# Shared by every smoke test in this foundation — see the `hub` skill (AGENTS.md).
#
# Do not add `common.hcl` (its hooks only serve `plan`) or a backend config: either puts cloud
# credentials back into a run that should need none.

locals {
  meshstack = {
    endpoint = "https://api.try.meshstack.io"

    # Created by ../smoke-test. Spelled out rather than read from its state, which is what this file
    # exists to avoid.
    workspace = "smoke-test"
  }

  # Also created by ../smoke-test, for STACKIT University offerings: see smoke-test/stackit.tf.
  stackit = {
    workspace      = "smoke-test-stackit"
    mesh_tenant_id = "TODO-after-applying-smoke-test"
  }
}

generate "provider" {
  path      = "provider.tf"
  if_exists = "overwrite"
  contents  = <<EOF
# CI authenticates with the smoke test's API key from MESHSTACK_API_KEY and MESHSTACK_API_SECRET,
# which ignores the workspace. A local run uses the meshstack CLI profile for the endpoint, whose
# user has a role in `meshcloud` and none in `smoke-test`.
provider "meshstack" {
  endpoint  = "${local.meshstack.endpoint}"
  workspace = "meshcloud"
}
EOF
}
