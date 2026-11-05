# Starterkit building blocks on the legacy versions put this token into their namespaces.
resource "stackit_modelserving_token" "this" {
  project_id  = var.stackit_project_id
  name        = "ske-starterkit-${var.template_name}"
  description = "ske-starterkit-${var.template_name}"
}
