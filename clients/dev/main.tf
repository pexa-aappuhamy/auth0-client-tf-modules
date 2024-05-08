module "test_m2m_dev_client" {
  source = "../../tf-modules/client/m2m"
  client_name = "Test M2M Dev Client 2"
  token_lifetime = 3600
  client_metadata = {}
  client_grants = [
    {
        audience = "https://api.example.com/client-grant"
        scopes = ["create:foo"]
    }
  ]
}

module "test_regular_dev_client" {
  source = "../../tf-modules/client/regular"
  client_name = "Test Regular Dev Client 2"
  client_metadata = {}
  web_origins = ["http://localhost:3000", "http://localhost:3001"]
}