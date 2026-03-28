# 1. El Cluster ECS
resource "aws_ecs_cluster" "main" {
  name = var.cluster_name

  setting {
    name  = "containerInsights"
    value = "enabled"
  }

  tags = {
    name = "csgtest" 
  }
}


# 2. Task Definition (La "receta" de tu contenedor)
resource "aws_ecs_task_definition" "app" {
  family                   = "${var.cluster_name}-task"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "256"
  memory                   = "512"
  execution_role_arn       = var.execution_role_arn
  task_role_arn            = var.task_role_arn

  container_definitions = jsonencode([{
    name      = "app-container"
    image     = var.ecr_image_url # Ahora usa la imagen real de ECR
    essential = true
    
    # Variables de entorno estándar (texto plano)
    environment = [
      { name = "APP_ENV", value = var.app_environment },
      { name = "DB_HOST", value = var.db_host },
      { name = "DB_NAME", value = "postgres" },
      { name = "DB_USER", value = "dbadmin" }
    ]
    
    # Secretos (ECS los va a buscar a Secrets Manager de forma segura)
    secrets = [
      {
        name      = "DB_PASSWORD"
        valueFrom = var.db_password_secret_arn
      }
    ]

    portMappings = [{
      containerPort = 3000
      hostPort      = 3000
      protocol      = tcp
    }]
    logConfiguration = {
      logDriver = "awslogs"
      options = {
        "awslogs-group"         = aws_cloudwatch_log_group.ecs_logs.name
        "awslogs-region"        = "us-east-1" # O la región que estés usando
        "awslogs-stream-prefix" = "app"
      }
    }
  }])
}

# 4. El Servicio ECS (El que mantiene las tareas corriendo)
resource "aws_ecs_service" "main" {
  name            = "${var.cluster_name}-service"
  cluster         = aws_ecs_cluster.main.id
  task_definition = aws_ecs_task_definition.app.arn
  desired_count   = 2
  launch_type     = "FARGATE"

  network_configuration {
    # Cambiamos la referencia antigua por la variable correcta
    security_groups  = [var.ecs_security_group_id] 
    subnets          = var.private_subnet_ids
    assign_public_ip = false
  }
 load_balancer {
    target_group_arn = var.target_group_arn
    container_name   = "app-container" # Debe coincidir exactamente con el nombre en container_definitions
    container_port   = 3000
  } 
}

resource "aws_cloudwatch_log_group" "ecs_logs" {
  name              = "/ecs/${var.cluster_name}"
  retention_in_days = 7

  tags = {
    name = "csgtest"
  }
} 