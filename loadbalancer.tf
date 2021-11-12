resource "aws_security_group" "mylbsg" {
  vpc_id = aws_vpc.myvpc.id

  ingress {
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
  tags = {
    Name = "mysg"
  }
}

resource "aws_security_group" "service_security_group" {
  vpc_id = aws_vpc.myvpc.id

  ingress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    security_groups = [aws_security_group.mylbsg.id]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "internalsg"
  }
}


resource "aws_alb" "myalb" {
  name               = "myalb"
  internal           = false
  load_balancer_type = "application"
  subnets            = aws_subnet.public.*.id
  security_groups    = [aws_security_group.mylbsg.id]

  tags = {
    Name = "myalb"
  }
}


resource "aws_lb_target_group" "target_group" {
  name        = "mytg"
  port        = 80
  protocol    = "HTTP"
  target_type = "ip"
  vpc_id      = aws_vpc.myvpc.id

  health_check {
    healthy_threshold   = "2"
    interval            = "10"
    protocol            = "HTTP"
    matcher             = "200"
    timeout             = "5"
    path                = "/v1/status"
    unhealthy_threshold = "2"
  }

  tags = {
    Name = "mytg"
  }
}

resource "aws_lb_listener" "listener" {
  load_balancer_arn = aws_alb.myalb.id
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.target_group.id
  }
}
