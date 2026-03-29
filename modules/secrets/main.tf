resource "aws_secretsmanager_secret" "db_password" {
  # Cambiamos 'name' por 'name_prefix' para evitar colisiones
  name_prefix             = "${var.environment}-db-password-"
  
  # Obligamos a AWS a borrar el secreto inmediatamente si hacemos un destroy
  recovery_window_in_days = 0 

  tags = {
    name        = "csgtest"
    Environment = var.environment
  }
}

# La versión inicial del secreto (en un entorno real, esto se inyecta por fuera o se autogenera)
resource "aws_secretsmanager_secret_version" "db_password_version" {
  secret_id     = aws_secretsmanager_secret.db_password.id
  secret_string = jsonencode({
    username = "dbadmin"
    password = var.db_password # Esta variable vendrá de tus variables de entorno o tfvars
  })
}