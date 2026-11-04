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

inputs = {
  hub_ref           = "00388ade2aa056e7ca72ca3189331da11794332a"
  forgejo_api_token = get_env("STACKIT_GIT_FORGEJO_TOKEN")
}
