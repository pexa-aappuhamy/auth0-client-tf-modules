resource "aws_secretsmanager_secret" this {
  name = format("/%s/%s", var.environment, lower(replace(var.client_name, " ", "-")))
  recovery_window_in_days = 0
}

resource "aws_secretsmanager_secret_version" this {
  secret_id     = aws_secretsmanager_secret.this.id
  secret_string = sensitive(jsonencode(var.client_credentials))
}