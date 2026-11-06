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
  hub_ref = "aa35ccb0074d5ccf58739d290422cdd9e762dff4"
}
