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

terraform {
  source = "git::https://github.com/meshcloud/meshstack-hub.git//modules/meshstack/link?ref=fc5f808"
}

inputs = {
  meshstack = {
    owning_workspace_identifier = "meshcloud"

    # The meshBuildingBlockDefinition.Company tag gates visibility: only workspaces whose own
    # Company tag matches can see and order this definition. Trial sign-ups arriving via
    # ?ref=stackit-university are tagged Company=stackit-university by the trial-starter.
    tags = { Company = ["stackit-university"] }
  }

  link_display_name = "STACKIT University"
  link_url          = "https://university.stackit.cloud"

  # Markdown lives in files rather than inline heredocs so it stays readable and diffable.
  # readme.md is the catalog entry shown before ordering, summary.md what the team gets after.
  link_readme  = file("${get_terragrunt_dir()}/readme.md")
  link_summary = file("${get_terragrunt_dir()}/summary.md")

  link_description         = "Free STACKIT training: e-learning, webinars, workshops and seminars, with certification."
  link_support_url         = "https://stackit.com/en/learn/stackit-university"
  link_documentation_url   = "https://stackit.com/en/learn/stackit-university"
  link_supported_platforms = []
  # The symbol is a graduation-cap glyph in STACKIT teal, inlined as a data URI so the icon
  # ships with this definition instead of depending on a URL we'd have to host elsewhere.
  link_symbol = "data:image/svg+xml;base64,${base64encode(file("${get_terragrunt_dir()}/symbol.svg"))}"

  # Released, not draft: trial workspaces instantiate this definition, and the trial-starter
  # resolves it by display name at sign-up time.
  hub = { git_ref = "fc5f808", bbd_draft = true }
}
