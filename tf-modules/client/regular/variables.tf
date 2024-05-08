variable client_name {
    type = string
    description = "Auth0 regular web client/application name"
}

variable allowed_logout_urls {
    type = list(string)
    description = "Allowed logout URLs"
    default = []
}

variable allowed_clients {
    type = list(string)
    description = "Allowed clients"
    default = []
}

variable allowed_origins {
    type = list(string)
    description = "Allowed origins"
    default = []
}

variable callback_urls {
    type = list(string)
    description = "Callback URLs"
    default = []
}

variable client_metadata {
    type = map(string)
    description = "Application metadata"
    default = {}
}

variable initiate_login_uri {
    type = string
    description = "Initiate login URI"
    default = ""
}

variable logo_uri {
    type = string
    description = "Logo URI"
    default = ""
}

variable web_origins {
    type = list(string)
    description = "Web origins"
    default = []
}

variable token_lifetime {
    type = number
    description = "Lifetime for Token"
    default = 3600
}

variable environment {
    type = string
    description = "Environment"
    default = "dev"
}

variable region {
    type = string
    description = "Auth0 region"
    default = "au"
}