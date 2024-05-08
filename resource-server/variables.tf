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
    })
    description = "Auth0 provider parameters"
}

variable "secrets" {
    type = object({
        auth0_client_secret        = string
    })
    description = "Auth0 secrets"
}