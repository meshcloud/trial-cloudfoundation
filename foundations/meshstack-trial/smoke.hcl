# Shared by every smoke test in this foundation — see the `hub` skill (AGENTS.md).
#
# Do not add `common.hcl` (its hooks only serve `plan`) or a backend config: either puts cloud
# credentials back into a run that should need none.

locals {
  meshstack = {
    endpoint = "https://api.try.meshstack.io"

    # The smoke test's own API user, separate from the ones the deployment units use: its secret is
    # the `smoke-test` environment's `MESHSTACK_API_SECRET`, so a new smoke test needs no new secret.
    apikey = "6bbe883a-c417-408c-8a93-a828d08e3d75"

    # Spelled out rather than looked up — the deployment units resolve the same value through
    # `data.meshstack_workspace`, and reaching for their state is what this file exists to avoid.
    workspace = "meshcloud"
  }
}

generate "provider" {
  path      = "provider.tf"
  if_exists = "overwrite"
  contents  = <<EOF
provider "meshstack" {
  endpoint  = "${local.meshstack.endpoint}"
  apikey    = "${local.meshstack.apikey}"
  apisecret = "${get_env("MESHSTACK_API_SECRET")}"
}
EOF
}
