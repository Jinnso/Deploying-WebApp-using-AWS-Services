# 1. SG para el Load Balancer (Acceso público)
resource "aws_security_group" "alb" {
  name        = "${var.environment}-alb-sg"
  description = "Permite trafico HTTP entrante desde internet"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    name        = "csgtest"
    Environment = var.environment
  }
}

# 2. SG para las tareas de ECS (Acceso solo desde el ALB)
resource "aws_security_group" "ecs" {
  name        = "${var.environment}-ecs-sg"
  description = "Permite trafico entrante solo desde el ALB"
  vpc_id      = var.vpc_id

  ingress {
    from_port       = 3000
    to_port         = 3000
    protocol        = "tcp"
    security_groups = [aws_security_group.alb.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    name        = "csgtest"
    Environment = var.environment
  }
}

# 3. SG para la Base de Datos RDS (Acceso solo desde ECS)
resource "aws_security_group" "rds" {
  name        = "${var.environment}-rds-sg"
  description = "Permite trafico a la BD solo desde las tareas de ECS"
  vpc_id      = var.vpc_id

  ingress {
    from_port       = 5432 # Cambiar a 3306 si usas MySQL
    to_port         = 5432
    protocol        = "tcp"
    security_groups = [aws_security_group.ecs.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    name        = "csgtest"
    Environment = var.environment
  }
}