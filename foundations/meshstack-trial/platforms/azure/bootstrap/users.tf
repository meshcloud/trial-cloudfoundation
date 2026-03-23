resource "azuread_invitation" "users" {
  for_each = var.users

  user_display_name  = each.value
  user_email_address = each.value
  redirect_url       = "https://portal.azure.com"

  message {
    body = <<EOT
You have been invited to join the Microsoft Entra ID tenant for the meshStack trial environment.
Please accept this invitation to gain access as a Global Administrator.
EOT
  }
}

resource "azuread_directory_role" "global_administrator" {
  display_name = "Global Administrator"
}

resource "azuread_directory_role_assignment" "global_administrator" {
  for_each = var.users

  role_id             = azuread_directory_role.global_administrator.template_id
  principal_object_id = azuread_invitation.users[each.key].user_id
}
