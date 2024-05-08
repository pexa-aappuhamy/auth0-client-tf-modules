module "test_m2m_common_client" {
  source = "../../tf-modules/client/m2m"
  client_name = "Test M2M Common Client 3"
  token_lifetime = 3600
  client_metadata = {}
  environment = var.environment
  client_grants = [
    {
        audience = "https://api.example.com/client-grant"
        scopes = ["create:foo"]
    }
  ]
}