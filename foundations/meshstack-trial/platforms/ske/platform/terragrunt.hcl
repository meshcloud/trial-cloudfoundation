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
  hub_ref           = "75077d6dcabc6824941d516c68129db846d4d3d8"
  forgejo_api_token = get_env("STACKIT_GIT_FORGEJO_TOKEN")
}
