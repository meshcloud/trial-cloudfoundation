output "sandboxes" {
  description = "Per sandbox number: its meshProject and its STACKIT project id."
  value = {
    for number, project in meshstack_project.sandbox : number => {
      project_identifier = project.metadata.name
      stackit_project_id = meshstack_tenant.sandbox[number].spec.platform_tenant_id
    }
  }
}
