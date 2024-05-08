terraform {
  required_version = "~> 1.3.4"
  required_providers {
    auth0 = {
      source  = "auth0/auth0"
      version = ">= 1.2.0"
    }
  }
}

provider "auth0" {
  debug = true
  domain = var.tenant.domain
  client_id = var.provider_.auth0.client_id
  client_secret = var.secrets.auth0_client_secret
}