include "common" {
  path = find_in_parent_folders("common.hcl")
}

generate "provider" {
  path      = "provider.tf"
  if_exists = "overwrite"
  contents  = <<EOF
provider "meshstack" {
  endpoint  = "https://api.try.meshstack.io"
  workspace = "meshcloud"
}
EOF
}

include "meshstack_identity_runner" {
  path   = find_in_parent_folders("meshstack_identity_runner.hcl")
  expose = true
}

inputs = {
  stackit_service_account_key = get_env("STACKIT_ORG_OWNER_SERVICE_ACCOUNT")
  runner_ref                  = include.meshstack_identity_runner.locals.runner_ref
}
