
resource "aws_ecr_repository" "api" {
  name                 = "levonovyi-gym-api"
  image_tag_mutability = "IMMUTABLE"
  force_delete         = true

  image_scanning_configuration {
    scan_on_push = true
  }

  tags = {
    Name = "levonovyi-gym-api"
  }
}
