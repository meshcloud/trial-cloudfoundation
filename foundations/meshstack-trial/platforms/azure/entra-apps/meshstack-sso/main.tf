data "azuread_client_config" "current" {}

data "azuread_application_published_app_ids" "well_known" {}

data "azuread_service_principal" "msgraph" {
  client_id = data.azuread_application_published_app_ids.well_known.result.MicrosoftGraph
}

resource "azuread_application" "keycloak_sso" {
  display_name     = var.display_name
  sign_in_audience = "AzureADandPersonalMicrosoftAccount"

  api {
    requested_access_token_version = 2
  }

  web {
    redirect_uris = var.redirect_uris

    implicit_grant {
      access_token_issuance_enabled = false
      id_token_issuance_enabled     = true
    }
  }

  # Minimal Microsoft Graph delegated scopes needed for Keycloak OIDC login.
  required_resource_access {
    resource_app_id = data.azuread_application_published_app_ids.well_known.result.MicrosoftGraph

    dynamic "resource_access" {
      for_each = toset(["openid", "email", "profile", "User.Read"])
      content {
        id   = data.azuread_service_principal.msgraph.oauth2_permission_scope_ids[resource_access.value]
        type = "Scope"
      }
    }
  }
}

resource "azuread_service_principal" "keycloak_sso" {
  client_id = azuread_application.keycloak_sso.client_id
}

resource "azuread_application_password" "keycloak_sso" {
  application_id = azuread_application.keycloak_sso.id
  display_name   = "keycloak-client-secret"
  end_date       = var.secret_expiry
}
