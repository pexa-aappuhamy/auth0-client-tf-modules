variable "tenant" {
    type    = object({
        domain                  = string
    })
    description = "Auth0 tenant parameters"
}

variable "provider_" {
    type = object({
        auth0 = object({
            client_id           = string
        })
        aws = object({
          access_key = string
          region = string
        })
    })

    validation {
        condition = var.provider_.aws.region == "ap-southeast-2"
        error_message = "Region must be ap-southeast-2"
    }
    description = "Auth0 provider parameters"
}

variable "secrets" {
    type = object({
        auth0_client_secret        = string
        aws_secret_key             = string
    })
    description = "Auth0 secrets"
}

variable "environment" {
    type = string
    description = "Environment"
}

variable test_regular_client_web_origins {
  type = list(string)
  description = "Web origins for the test regular client"
}