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

include "hub" {
  path   = "hub.hcl"
  expose = true
}

inputs = {
  hub_ref = include.hub.locals.git_ref
}
