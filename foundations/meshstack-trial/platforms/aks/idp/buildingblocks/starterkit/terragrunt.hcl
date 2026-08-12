include "common" {
  path = find_in_parent_folders("common.hcl")
}

dependency "platform" {
  config_path = "../../platform"
  mock_outputs = {
    platform_ref = { uuid = "c26adcd4-e506-4159-b327-501470e3eddf", kind = "meshPlatform" }
    landing_zone_refs = {
      dev  = { name = "aks-namespace-dev", kind = "meshLandingZone" }
      prod = { name = "aks-namespace-prod", kind = "meshLandingZone" }
    }
  }
  mock_outputs_allowed_terraform_commands = ["plan", "validate", "init", "output"]
  mock_outputs_merge_strategy_with_state  = "shallow"
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
  source = "git::https://github.com/meshcloud/meshstack-hub.git//modules/aks/starterkit?ref=43ee4fc7ed51000d5b9b6764292eb8f7156651ad"
}

inputs = {
  meshstack = {
    owning_workspace_identifier = dependency.platform.outputs.owned_by_workspace
  }

  platform_ref      = dependency.platform.outputs.platform_ref
  landing_zone_refs = dependency.platform.outputs.landing_zone_refs

  building_block_definition_version_refs = {
    "git-repository"           = dependency.github_repo.outputs.building_block_definition.version_ref
    "github-actions-connector" = dependency.connector.outputs.building_block_definition.version_ref
  }

  github_org                = "try-meshstack"
  github_template_repo_path = "try-meshstack/aks-starterkit-template"

  hub = { git_ref = "43ee4fc7ed51000d5b9b6764292eb8f7156651ad", bbd_draft = false }

  # this is only for app link outputs so the link is rendered correctly when we change the base domain.
  apps_base_domain = "try-meshstack.msh.host"

  tags                     = {}
  notification_subscribers = []
  project_tags = {
    dev  = {}
    prod = {}
  }
}
