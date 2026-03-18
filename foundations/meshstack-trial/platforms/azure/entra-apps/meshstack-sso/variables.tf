variable "display_name" {
  description = "Display name shown in the Microsoft login consent screen and Entra ID app registrations."
  type        = string
  default     = "Keycloak SSO (meshStack Trial)"
}

variable "redirect_uris" {
  description = <<-EOT
    OAuth2 redirect URIs for the Keycloak OIDC identity provider callback.
    Format: https://<keycloak-host>/realms/<realm>/broker/microsoft/endpoint
  EOT
  type        = list(string)
}

variable "secret_expiry" {
  description = "Expiry date for the client secret in RFC3339 format. Rotate before this date."
  type        = string
  default     = null
}
