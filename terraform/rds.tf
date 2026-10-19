
resource "aws_db_subnet_group" "main" {
  name = "levonovyi-db-subnets"

  subnet_ids = [
    aws_subnet.private_1.id,
    aws_subnet.private_2.id
  ]

  tags = {
    Name = "levonovyi-db-subnets"
  }
}

resource "aws_db_instance" "mysql" {
  identifier = "levonovyi-gym-mysql"

  engine         = "mysql"
  engine_version = "8.4.11"

  instance_class    = "db.t4g.micro"
  allocated_storage = 20
  storage_type      = "gp3"

  db_name  = "gym_db"
  username = "gym_admin"

  manage_master_user_password = true

  db_subnet_group_name   = aws_db_subnet_group.main.name
  vpc_security_group_ids = [aws_security_group.db.id]
  publicly_accessible    = false

  multi_az            = false
  skip_final_snapshot = true
  deletion_protection = false

  backup_retention_period = 1

  tags = {
    Name = "levonovyi-gym-mysql"
  }
}
