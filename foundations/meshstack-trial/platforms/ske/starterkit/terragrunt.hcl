include "common" {
  path = find_in_parent_folders("common.hcl")
}

generate "provider" {
  path      = "provider.tf"
  if_exists = "overwrite"
  contents  = <<EOF2
provider "stackit" {
  default_region      = "eu01"
  service_account_key = ${jsonencode(get_env("STACKIT_SKE_PROJECT_SERVICE_ACCOUNT_KEY"))}
}
EOF2
}

inputs = {
  stackit_project_id = "aa05c781-6026-49be-90e4-44d8314dec6d"
  template_name      = "ai-summarizer"
}
