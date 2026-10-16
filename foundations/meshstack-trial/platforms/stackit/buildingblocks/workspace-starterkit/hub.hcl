# Hub building-block coordinates — single source of truth for both the deployment
# (terragrunt.hcl) and the e2e smoke test (e2e/terragrunt.hcl).
locals {
  module  = "meshstack/workspace-starterkit"
  git_ref = "9c13aec4cc3f43b7f6cbc8051710414b3ca3c95a"

  # Vital: keeps this BBD in draft. A draft BBD is only orderable from its owning workspace
  # (meshcloud), never published to the marketplace — we want this hidden, not offered generally.
  bbd_draft = true
}
