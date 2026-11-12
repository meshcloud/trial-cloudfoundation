# Hub building-block coordinates — single source of truth for both the deployment
# (terragrunt.hcl) and the e2e smoke test (e2e/terragrunt.hcl).
locals {
  module  = "meshstack/workspace-starterkit"
  git_ref = "707c7f8e9e141df82f0ec75b5a4f8bbdc1a3e7df"

  # Vital: keeps this BBD in draft. A draft BBD is only orderable from its owning workspace
  # (meshcloud), never published to the marketplace — we want this hidden, not offered generally.
  bbd_draft = true
}
