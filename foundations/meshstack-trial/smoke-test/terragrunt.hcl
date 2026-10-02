include "common" {
  path = find_in_parent_folders("common.hcl")
}

generate "provider" {
  path      = "provider.tf"
  if_exists = "overwrite"
  contents  = <<EOF
# Runs as the meshstack-cli login whose profile matches this endpoint; it must be in the admin area.
provider "meshstack" {
  endpoint = "https://api.try.meshstack.io"
}

provider "github" {
  owner = "meshcloud"
}
EOF
}
