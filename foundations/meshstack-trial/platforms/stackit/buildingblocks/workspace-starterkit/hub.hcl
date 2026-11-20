# Hub building-block coordinates — single source of truth for both the deployment
# (terragrunt.hcl) and the e2e smoke test (e2e/terragrunt.hcl).
locals {
  module  = "meshstack/workspace-starterkit"
  git_ref = "796cad6e5b68a4c8cfaa5ca6d4e672255ce0a784"

  # Vital: keeps this BBD in draft. A draft BBD is only orderable from its owning workspace
  # (meshcloud), never published to the marketplace — we want this hidden, not offered generally.
  bbd_draft = true
}
