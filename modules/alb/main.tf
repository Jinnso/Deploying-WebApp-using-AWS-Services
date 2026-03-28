resource "aws_lb" "main" {
  name               = "${var.environment}-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [var.alb_security_group_id]
  subnets            = var.public_subnet_ids # El ALB sí va en las públicas

  tags = {
    name = "csgtest"
  }
}

resource "aws_lb_target_group" "app" {
  name        = "${var.environment}-tg"
  port        = 3000
  protocol    = "HTTP"
  vpc_id      = var.vpc_id
  target_type = "ip" # Requerido para AWS Fargate

  health_check {
    path                = "/"
    healthy_threshold   = 2
    unhealthy_threshold = 10
  }

  tags = {
    name = "csgtest"
  }
}

resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.main.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.app.arn
  }
}