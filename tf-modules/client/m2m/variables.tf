variable client_name {
    type = string
    description = "Auth0 m2m client/application name"
}

variable token_lifetime {
    type = number
    description = "Lifetime for JWT"
    default = 3600
}

variable client_metadata {
    type = map(string)
    description = "Application metadata"
    default = {}
}

variable environment {
    type = string
    description = "Environment"
}

variable "client_grants" {
  description = "List of client grants"
  type = list(object({
    audience = string
    scopes   = list(string)
  }))
  default = []
}