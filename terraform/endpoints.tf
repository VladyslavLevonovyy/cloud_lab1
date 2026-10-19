
resource "aws_route_table" "private" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "levonovyi-private-rt"
  }
}

resource "aws_route_table_association" "private_1" {
  subnet_id      = aws_subnet.private_1.id
  route_table_id = aws_route_table.private.id
}

resource "aws_route_table_association" "private_2" {
  subnet_id      = aws_subnet.private_2.id
  route_table_id = aws_route_table.private.id
}

resource "aws_security_group" "endpoints" {
  name        = "levonovyi-endpoints-sg"
  description = "Security group for VPC endpoints"
  vpc_id      = aws_vpc.main.id
}

resource "aws_vpc_security_group_ingress_rule" "endpoints_https" {
  security_group_id            = aws_security_group.endpoints.id
  referenced_security_group_id = aws_security_group.api.id

  from_port   = 443
  to_port     = 443
  ip_protocol = "tcp"
}

resource "aws_vpc_security_group_egress_rule" "api_to_endpoints" {
  security_group_id            = aws_security_group.api.id
  referenced_security_group_id = aws_security_group.endpoints.id

  from_port   = 443
  to_port     = 443
  ip_protocol = "tcp"
}

resource "aws_vpc_endpoint" "services" {
  for_each = toset([
    "ecr.api",
    "ecr.dkr",
    "logs",
    "secretsmanager"
  ])

  vpc_id              = aws_vpc.main.id
  service_name        = "com.amazonaws.eu-north-1.${each.value}"
  vpc_endpoint_type   = "Interface"
  subnet_ids          = [aws_subnet.private_1.id]
  security_group_ids  = [aws_security_group.endpoints.id]
  private_dns_enabled = true

  tags = {
    Name = "levonovyi-${replace(each.value, ".", "-")}"
  }
}

resource "aws_vpc_endpoint" "s3" {
  vpc_id            = aws_vpc.main.id
  service_name      = "com.amazonaws.eu-north-1.s3"
  vpc_endpoint_type = "Gateway"

  route_table_ids = [
    aws_route_table.private.id
  ]

  tags = {
    Name = "levonovyi-s3-endpoint"
  }
}

data "aws_prefix_list" "s3" {
  name = "com.amazonaws.eu-north-1.s3"
}

resource "aws_vpc_security_group_egress_rule" "api_to_s3" {
  security_group_id = aws_security_group.api.id

  prefix_list_id = data.aws_prefix_list.s3.id

  from_port   = 443
  to_port     = 443
  ip_protocol = "tcp"
}
