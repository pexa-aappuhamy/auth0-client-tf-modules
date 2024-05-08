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