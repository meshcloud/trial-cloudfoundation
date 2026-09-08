# Shared by every smoke test in this foundation — see the `hub` skill (AGENTS.md).
#
# Do not add `common.hcl` (its hooks only serve `plan`) or a backend config: either puts cloud
# credentials back into a run that should need none.

locals {
  meshstack = {
    endpoint = "https://api.try.meshstack.io"

    # The key id comes from Vault like the secret does, matching the sibling `ske` units. The rest
    # of this repo commits its key id instead — see AGENTS.md.
    apikey    = get_env("MESHSTACK_STARTER_KIT_API_KEY_ID")
    apisecret = get_env("MESHSTACK_STARTER_KIT_API_KEY_SECRET")

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
  apisecret = "${local.meshstack.apisecret}"
}
EOF
}
