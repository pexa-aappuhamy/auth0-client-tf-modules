resource "auth0_resource_server" "test_api" {
  name       = "Test API"
  identifier = "https://api.example.com/client-grant"
}

resource "auth0_resource_server_scopes" "test_api" {
 resource_server_identifier = auth0_resource_server.test_api.identifier

  scopes {
    name       = "create:foo"
    description = "Create foos"
  }

  scopes {
    name       = "create:bar"
    description = "Create bars"
  }
}