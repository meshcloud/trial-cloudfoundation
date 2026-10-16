include "common" {
  path = find_in_parent_folders("common.hcl")
}

generate "provider" {
  path      = "provider.tf"
  if_exists = "overwrite"
  contents  = <<EOF
provider "meshstack" {
  endpoint  = "https://api.try.meshstack.io"
}
EOF
}

# Hub coordinates live in hub.hcl (single source of truth, shared with e2e/).
include "hub" {
  path   = "./hub.hcl"
  expose = true
}

inputs = {
  hub = {
    git_ref   = include.hub.locals.git_ref
    bbd_draft = include.hub.locals.bbd_draft
  }
}
