include "common" {
  path = find_in_parent_folders("common.hcl")
}

dependency "platform" {
  config_path = "../../platform"
}

dependency "github_repo" {
  config_path = "../github-repo"
}

dependency "connector" {
  config_path = "../connector"
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
  source = "git::https://github.com/meshcloud/meshstack-hub.git//modules/aks/starterkit?ref=feature/aks-starterkit-integration"
}

inputs = {
  meshstack = {
    owning_workspace_identifier = dependency.platform.outputs.owned_by_workspace
  }
  full_platform_identifier                         = dependency.platform.outputs.full_platform_identifier
  landing_zone_dev_identifier                      = dependency.platform.outputs.landing_zone_dev_identifier
  landing_zone_prod_identifier                     = dependency.platform.outputs.landing_zone_prod_identifier
  github_org                                       = "try-meshstack"
  github_repo_definition_uuid                      = dependency.github_repo.outputs.building_block_definition_uuid
  github_repo_definition_version_uuid              = dependency.github_repo.outputs.building_block_definition_version_uuid
  github_actions_connector_definition_version_uuid = dependency.connector.outputs.building_block_definition_version_uuid
  hub                                              = { git_ref = "feature/aks-starterkit-integration" }
  tags                                             = {}
  template_owner                                   = "try-meshstack"
  template_repo                                    = "aks-starterkit-template"
  notification_subscribers                         = []
  project_tags_yaml                                = <<-YAML
    dev: {}
    prod: {}
  YAML
}
