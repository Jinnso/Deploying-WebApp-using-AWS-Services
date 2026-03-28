# Grupo de subredes para que la base de datos viva en las redes privadas
resource "aws_db_subnet_group" "main" {
  name       = "${var.environment}-rds-subnet-group"
  subnet_ids = var.private_subnet_ids

  tags = {
    name = "csgtest"
  }
}

resource "aws_db_instance" "main" {
  identifier             = "${var.environment}-database"
  allocated_storage      = 20
  engine                 = "postgres" # Puedes usar mysql si lo prefieres
  engine_version         = "14"
  instance_class         = var.db_instance_class # Permite variar entre test y prod
  db_subnet_group_name   = aws_db_subnet_group.main.name
  vpc_security_group_ids = [var.rds_security_group_id]
  skip_final_snapshot    = true # Útil para destruir entornos de prueba rápido

  # Las credenciales deberían consumirse del módulo de secretos o variables seguras
  username = "dbadmin"
  password = var.db_password 

  tags = {
    name        = "csgtest"
    Environment = var.environment
  }
}