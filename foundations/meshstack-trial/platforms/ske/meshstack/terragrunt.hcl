include "common" {
  path = find_in_parent_folders("common.hcl")
}

generate "provider" {
  path      = "provider.tf"
  if_exists = "overwrite"
  contents  = <<EOF
provider "meshstack" {
  endpoint  = "https://api.try.meshstack.io"
  apikey    = "${get_env("MESHSTACK_STARTER_KIT_API_KEY_ID")}"
  apisecret = "${get_env("MESHSTACK_STARTER_KIT_API_KEY_SECRET")}"
}
EOF
}
