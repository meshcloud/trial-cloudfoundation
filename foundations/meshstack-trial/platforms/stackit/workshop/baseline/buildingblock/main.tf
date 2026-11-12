variable "project_id" {
  type        = string
  nullable    = false
  description = "STACKIT project of the sandbox."
}

# An example of a cheap resource every sandbox gets. Replace it with what your workshop needs.
resource "stackit_authorization_project_custom_role" "workshop_viewer" {
  resource_id = var.project_id
  name        = "workshop.viewer"
  description = "Can look up project members. Created by the workshop baseline."
  permissions = ["iam.subject.get"]
}
