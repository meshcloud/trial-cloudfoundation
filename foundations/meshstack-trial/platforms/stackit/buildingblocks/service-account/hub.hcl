# Hub building-block coordinates — single source of truth for both the deployment
# (terragrunt.hcl) and the e2e smoke test (e2e/terragrunt.hcl).
#
# `module` is only consumed by e2e/: the deployment composes two hub modules and names their paths
# itself. The federation's e2e covers both, because it orders a service account to federate.
locals {
  module = "stackit/service-account-federation"
  # Points at feature/stackit-service-account-e2e-modes, which adds the e2e. Bump to the merged main
  # SHA once that hub PR lands.
  git_ref = "e4ad934881898f585c897095da743eb1212640f1"

  # Released, not draft: workshop workspaces order these, and only a release is orderable from a
  # workspace other than the owner.
  bbd_draft = false
}
