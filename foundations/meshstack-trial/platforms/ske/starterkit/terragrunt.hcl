include "common" {
  path = find_in_parent_folders("common.hcl")
}

dependency "meshstack" {
  config_path = "../meshstack"
}

dependency "platform" {
  config_path = "../meshstack/platform"
}

dependency "git" {
  config_path = "../git"
}

dependency "kubernetes" {
  config_path = "../kubernetes"
}

dependency "dns" {
  config_path = "../dns"
}

locals {
  hub = {
    git_ref   = "43c0b2aac6e328af7968839c9e81c85af2c88cc6"
    bbd_draft = false
  }
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

provider "stackit" {
  default_region      = "eu01"
  service_account_key = ${jsonencode(get_env("STACKIT_SKE_PROJECT_SERVICE_ACCOUNT_KEY"))}
}
EOF
}

inputs = {
  meshstack = dependency.meshstack.outputs
  hub       = local.hub

  full_platform_identifier = dependency.platform.outputs.full_platform_identifier
  landing_zone_identifiers = dependency.platform.outputs.landing_zone_identifiers

  kubeconfig = dependency.kubernetes.outputs.kubeconfig

  forgejo_token        = dependency.git.outputs.forgejo_token
  forgejo_base_url     = dependency.git.outputs.forgejo_base_url
  forgejo_organization = dependency.git.outputs.forgejo_organization

  stackit_project_id = dependency.meshstack.outputs.stackit_project_id

  stackit_harbor_project = "try_meshstack"

  # No way to provision those robot users with TF at the moment :(
  stackit_harbor_push_robot_user     = get_env("STACKIT_HARBOR_PUSH_ROBOT_USER")
  stackit_harbor_push_robot_password = get_env("STACKIT_HARBOR_PUSH_ROBOT_PASSWORD")
  stackit_harbor_pull_robot_user     = get_env("STACKIT_HARBOR_PULL_ROBOT_USER")
  stackit_harbor_pull_robot_password = get_env("STACKIT_HARBOR_PULL_ROBOT_PASSWORD")

  # Template name and base template repository should align
  template_name           = "ai-summarizer"
  template_repo_clone_url = "https://github.com/likvid-bank/starterkit-template-stackit-ai-summarizer.git"
  dns_zone_name           = dependency.dns.outputs.zone_name
  add_random_name_suffix  = true

  project_tags = {
    owner_tag_key = null
    dev           = {}
    prod          = {}
  }
}
