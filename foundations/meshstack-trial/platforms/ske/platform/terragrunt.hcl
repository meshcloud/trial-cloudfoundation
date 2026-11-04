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
  hub_ref           = "bcf874845e1dc2533917379c9bb169fb31a7eff4"
  forgejo_api_token = get_env("STACKIT_GIT_FORGEJO_TOKEN")
}
