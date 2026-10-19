
resource "aws_cloudwatch_log_group" "api" {
  name              = "/ecs/levonovyi-gym-api"
  retention_in_days = 7

  tags = {
    Name = "levonovyi-gym-api-logs"
  }
}

resource "aws_ecs_cluster" "main" {
  name = "levonovyi-gym-cluster"

  tags = {
    Name = "levonovyi-gym-cluster"
  }
}

resource "aws_ecs_task_definition" "api" {
  family                   = "levonovyi-gym-api"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"

  cpu    = "256"
  memory = "512"

  execution_role_arn = aws_iam_role.ecs_execution.arn

  container_definitions = jsonencode([
    {
      name      = "gym-api"
      image     = "${aws_ecr_repository.api.repository_url}:fix-crypto"
      essential = true

      portMappings = [
        {
          containerPort = 5000
          protocol      = "tcp"
        }
      ]

      environment = [
        {
          name  = "DB_HOST"
          value = aws_db_instance.mysql.address
        },
        {
          name  = "DB_PORT"
          value = "3306"
        },
        {
          name  = "DB_NAME"
          value = "gym_db"
        },
        {
          name  = "DB_USER"
          value = "gym_admin"
        }
      ]

      secrets = [
        {
          name      = "DB_PASSWORD"
          valueFrom = "${aws_db_instance.mysql.master_user_secret[0].secret_arn}:password::"
        }
      ]

      logConfiguration = {
        logDriver = "awslogs"

        options = {
          "awslogs-group"         = aws_cloudwatch_log_group.api.name
          "awslogs-region"        = "eu-north-1"
          "awslogs-stream-prefix" = "ecs"
        }
      }
    }
  ])
}

resource "aws_ecs_service" "api" {
  name            = "levonovyi-gym-service"
  cluster         = aws_ecs_cluster.main.id
  task_definition = aws_ecs_task_definition.api.arn

  desired_count = 1
  launch_type   = "FARGATE"

  network_configuration {
    subnets = [
      aws_subnet.private_1.id
    ]

    security_groups = [
      aws_security_group.api.id
    ]

    assign_public_ip = false
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.api.arn
    container_name   = "gym-api"
    container_port   = 5000
  }

  health_check_grace_period_seconds = 60

  lifecycle {
    ignore_changes = [task_definition]
  }

  depends_on = [
    aws_lb_listener.http,
    aws_iam_role_policy_attachment.ecs_execution,
    aws_iam_role_policy.ecs_secrets,
    aws_vpc_endpoint.services,
    aws_vpc_endpoint.s3,
    aws_vpc_security_group_ingress_rule.endpoints_https,
    aws_vpc_security_group_egress_rule.api_to_endpoints,
    aws_vpc_security_group_egress_rule.api_to_s3,
    aws_vpc_security_group_ingress_rule.api_from_alb,
    aws_vpc_security_group_egress_rule.alb_to_api,
    aws_vpc_security_group_egress_rule.api_to_db,
    aws_vpc_security_group_ingress_rule.db_from_api
  ]
}
