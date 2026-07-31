include "common" {
  path = find_in_parent_folders("common.hcl")
}

generate "provider" {
  path      = "provider.tf"
  if_exists = "overwrite"
  contents  = <<EOF
provider "meshstack" {
  endpoint  = "https://api.try.meshstack.io"
    apikey    = "a17b9ad7-14c8-44cc-94ef-cb6b4db7ac8a"
    apisecret = "${get_env("MESHSTACK_API_SECRET_AKS_IDP")}"
}
EOF
}

inputs = {
  stackit_service_account_key = get_env("STACKIT_ORG_OWNER_SERVICE_ACCOUNT")
}
