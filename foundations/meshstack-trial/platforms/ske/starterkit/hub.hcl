# Hub building-block coordinates — single source of truth for both the deployment
# (terragrunt.hcl) and the e2e smoke test (e2e/terragrunt.hcl).
#
# `module` is only consumed by e2e/: the deployment composes three hub modules (the starter kit and
# the two definitions it creates child building blocks from), so it names their paths itself.
locals {
  module  = "ske/ske-starterkit"
  git_ref = "9c13aec4cc3f43b7f6cbc8051710414b3ca3c95a"

  # Released, not draft: trial users order this definition themselves.
  bbd_draft = false
}
