include "common" {
  path = find_in_parent_folders("common.hcl")
}

dependency "platform" {
  config_path = "../../platform"
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

terraform {
  source = "git::https://github.com/meshcloud/meshstack-hub.git//modules/github/repository?ref=6e1db6139d2c4d53761a0dd3a8d25aa61b6406c7"
}

inputs = {
  meshstack = {
    owning_workspace_identifier = dependency.platform.outputs.owned_by_workspace
  }
  github = {
    org                 = "try-meshstack"
    app_id              = get_env("GITHUB_APP_ID")
    app_installation_id = get_env("GITHUB_APP_INSTALLATION_ID")
    app_pem_file        = get_env("GITHUB_APP_PEM_FILE")
  }
  hub                      = { git_ref = "6e1db6139d2c4d53761a0dd3a8d25aa61b6406c7", bbd_draft = false }
  tags                     = {}
  notification_subscribers = []
}
