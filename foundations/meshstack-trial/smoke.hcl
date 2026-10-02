# Shared by every smoke test in this foundation — see the `hub` skill (AGENTS.md).
#
# Do not add `common.hcl` (its hooks only serve `plan`) or a backend config: either puts cloud
# credentials back into a run that should need none.

locals {
  meshstack = {
    endpoint = "https://api.try.meshstack.io"

    # The smoke test's own API user, separate from the ones the deployment units use: its secret is
    # the `smoke-test` environment's `MESHSTACK_API_SECRET`, so a new smoke test needs no new secret.
    apikey = "10b9892e-54b5-4a32-be35-c89ae37a159c"

    # Created by ../smoke-test. Spelled out rather than read from its state, which is what this file
    # exists to avoid.
    workspace = "smoke-test"
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
