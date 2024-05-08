resource "auth0_client" this {
  name                                = var.client_name
  allowed_clients = var.allowed_clients
  allowed_logout_urls = var.allowed_logout_urls
  allowed_origins = var.allowed_origins
  app_type        = "regular_web"
  callbacks = var.callback_urls
  client_aliases = []
  client_metadata = var.client_metadata
  cross_origin_auth                   = false
  cross_origin_loc                    = null
  custom_login_page                   = null
  custom_login_page_on                = true
  description                         = null
  form_template                       = null
  grant_types                         = ["authorization_code", "refresh_token"]
  initiate_login_uri                  = var.initiate_login_uri
  is_first_party                      = true
  is_token_endpoint_ip_header_trusted = false
  logo_uri                            = var.logo_uri
  
  oidc_backchannel_logout_urls        = []
  oidc_conformant                     = true
  organization_require_behavior       = "no_prompt"
  organization_usage                  = null
  sso                                 = false
  sso_disabled                        = false
  web_origins                         = var.web_origins
  jwt_configuration {
    alg                 = "RS256"
    lifetime_in_seconds = var.token_lifetime
    scopes              = {}
    secret_encoded      = false
  }
  native_social_login {
    apple {
      enabled = false
    }
    facebook {
      enabled = false
    }
  }
  refresh_token {
    expiration_type              = "non-expiring"
    idle_token_lifetime          = 2592000
    infinite_idle_token_lifetime = true
    infinite_token_lifetime      = true
    leeway                       = 0
    rotation_type                = "non-rotating"
    token_lifetime               = 31557600
  }
}

resource "auth0_client_credentials" this {
  depends_on = [auth0_client.this]
  client_id             = auth0_client.this.client_id
  authentication_method = "client_secret_post"
}

module "auth0_client_credentials" {
  depends_on = [ auth0_client.this, auth0_client_credentials.this ]
  source = "../credentials"
  environment = var.environment
  client_name = var.client_name
  client_credentials = {
    client_id = auth0_client.this.client_id
    client_secret = auth0_client_credentials.this.client_secret
  }
}