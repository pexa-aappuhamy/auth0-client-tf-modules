terraform {
  required_version = "~> 1.3.4"
  required_providers {
    auth0 = {
      source  = "auth0/auth0"
      version = ">= 1.2.0"
    }
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.16.0"
    }
  }
}

provider "auth0" {
  debug = true
  domain = var.tenant.domain
  client_id = var.provider_.auth0.client_id
  client_secret = var.secrets.auth0_client_secret
}

provider "aws" {
  region = var.provider_.aws.region
  access_key = var.provider_.aws.access_key
  secret_key = var.secrets.aws_secret_key
}