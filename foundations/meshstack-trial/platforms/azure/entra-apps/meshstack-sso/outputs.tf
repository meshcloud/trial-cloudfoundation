output "tenant_id" {
  description = "Azure AD tenant ID. Use as the base for the OIDC issuer URL in Keycloak."
  value       = data.azuread_client_config.current.tenant_id
}

output "client_id" {
  description = "Application (client) ID. Set as 'Client ID' in Keycloak's Microsoft identity provider."
  value       = azuread_application.keycloak_sso.client_id
}

# SENSITIVE: stored encrypted in the GCS Terraform state backend.
# Retrieve with: terragrunt output -raw client_secret
# Never print or commit this value.
output "client_secret" {
  description = "Client secret value. Set as 'Client Secret' in Keycloak's Microsoft identity provider. SENSITIVE."
  value       = azuread_application_password.keycloak_sso.value
  sensitive   = true
}

output "oidc_discovery_url" {
  description = <<-EOT
    OIDC discovery URL to use in Keycloak's Microsoft identity provider.
    The /common/ endpoint accepts both organisational and personal Microsoft accounts,
    matching the AzureADandPersonalMicrosoftAccount sign_in_audience set on the app.
  EOT
  value       = "https://login.microsoftonline.com/common/v2.0/.well-known/openid-configuration"
}

output "secret_expiry" {
  description = "Date on which the client secret expires. Rotate the secret before this date."
  value       = var.secret_expiry
}
