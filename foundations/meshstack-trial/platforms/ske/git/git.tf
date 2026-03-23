variable "stackit_project_id" {
  description = "STACKIT project UUID"
  type        = string
}

variable "forgejo_organization" {
  description = "Forgejo organization that should exist in the STACKIT Git instance"
  type        = string
}

resource "stackit_git" "this" {
  project_id = var.stackit_project_id
  name       = var.forgejo_organization
}

moved {
  from = stackit_git.git
  to   = stackit_git.this
}

import {
  to = stackit_git.this
  id = "${var.stackit_project_id},bddcefe5-004c-4a7a-b40e-decc66d3649c"
}

# this direct input to output mapping looks funny, but reflects the manual step when bootstrapping a stackit_git instance
# which requires creating a Personal Access Token for a Bot Account (shared platform engineering account)
# At least we can use it here to create the Org within the (shared) Forgejo Instance
variable "forgejo_token" {
  type      = string
  sensitive = true
}


provider "forgejo" {
  host      = stackit_git.this.url
  api_token = var.forgejo_token
}

resource "forgejo_organization" "this" {
  name       = var.forgejo_organization
  visibility = "private"
}

output "forgejo_token" {
  value     = var.forgejo_token
  sensitive = true
}

output "forgejo_base_url" {
  value = stackit_git.this.url
}

output "forgejo_organization" {
  value = forgejo_organization.this.name
}
