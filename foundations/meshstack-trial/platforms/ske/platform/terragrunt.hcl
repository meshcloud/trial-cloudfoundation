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
  hub_ref = "fef0ef7c10c0eb31ee0edbffd3354b2049d74a3a"
}
