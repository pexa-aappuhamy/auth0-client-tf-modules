variable environment {
    type = string
    description = "Environment"
}

variable client_credentials {
    type = object({
        client_id = string
        client_secret = string
    })
    description = "Auth0 client credentials"
}

variable client_name {
    type = string
    description = "Auth0 client name"
}