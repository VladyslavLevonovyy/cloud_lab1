
resource "aws_security_group" "alb" {
  name        = "levonovyi-alb-sg"
  description = "Security group for ALB"
  vpc_id      = aws_vpc.main.id

  tags = {
    Name = "levonovyi-alb-sg"
  }
}

resource "aws_vpc_security_group_ingress_rule" "alb_http" {
  security_group_id = aws_security_group.alb.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 80
  to_port           = 80
  ip_protocol       = "tcp"
}

resource "aws_vpc_security_group_egress_rule" "alb_to_api" {
  security_group_id            = aws_security_group.alb.id
  referenced_security_group_id = aws_security_group.api.id
  from_port                    = 5000
  to_port                      = 5000
  ip_protocol                  = "tcp"
}

resource "aws_security_group" "api" {
  name        = "levonovyi-api-sg"
  description = "Security group for Flask API"
  vpc_id      = aws_vpc.main.id

  tags = {
    Name = "levonovyi-api-sg"
  }
}

resource "aws_vpc_security_group_ingress_rule" "api_from_alb" {
  security_group_id            = aws_security_group.api.id
  referenced_security_group_id = aws_security_group.alb.id
  from_port                    = 5000
  to_port                      = 5000
  ip_protocol                  = "tcp"
}

resource "aws_vpc_security_group_egress_rule" "api_to_db" {
  security_group_id            = aws_security_group.api.id
  referenced_security_group_id = aws_security_group.db.id
  from_port                    = 3306
  to_port                      = 3306
  ip_protocol                  = "tcp"
}

resource "aws_security_group" "db" {
  name        = "levonovyi-db-sg"
  description = "Security group for MySQL RDS"
  vpc_id      = aws_vpc.main.id

  tags = {
    Name = "levonovyi-db-sg"
  }
}

resource "aws_vpc_security_group_ingress_rule" "db_from_api" {
  security_group_id            = aws_security_group.db.id
  referenced_security_group_id = aws_security_group.api.id
  from_port                    = 3306
  to_port                      = 3306
  ip_protocol                  = "tcp"
}
