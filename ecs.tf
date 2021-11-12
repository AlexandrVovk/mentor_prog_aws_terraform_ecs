resource "aws_ecs_cluster" "mycluster" {
  name = "mycluster"
  tags = {
    Name = "mycluster"
  }
}

resource "aws_ecs_task_definition" "mytd" {
  family = "mytd"

  container_definitions = jsonencode(
    [
      {
        name      = "mycontainer"
        image     = "nginx:latest"
        cpu       = 256
        memory    = 512
        essential = true
        portMappings = [
          {
            containerPort = 80
            hostPort      = 80
          }
        ]
      },
  ])

  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  memory                   = "512"
  cpu                      = "256"

  tags = {
    Name = "mytd"
  }
}

resource "aws_ecs_service" "aws-ecs-service" {
  name    = "aws-ecs-service"
  cluster = aws_ecs_cluster.mycluster.id
  # task_definition      = "${aws_ecs_task_definition.mytd.family}:${max(aws_ecs_task_definition.mytd.revision, data.aws_ecs_task_definition.main.revision)}"
  task_definition      = aws_ecs_task_definition.mytd.arn
  launch_type          = "FARGATE"
  scheduling_strategy  = "REPLICA"
  desired_count        = 2
  force_new_deployment = true

  network_configuration {
    subnets          = aws_subnet.private.*.id
    assign_public_ip = false
    security_groups = [
      aws_security_group.service_security_group.id,
      aws_security_group.mylbsg.id
    ]
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.target_group.arn
    container_name   = "mycontainer"
    container_port   = 80
  }

  depends_on = [aws_lb_listener.listener]
}
