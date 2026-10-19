
resource "aws_iam_user" "github_deployer" {
  name = "levonovyi-github-deployer"

  tags = {
    Name = "levonovyi-github-deployer"
  }

  lifecycle {
    ignore_changes = [tags]
  }
}

resource "aws_iam_user_policy" "github_deployer" {
  name = "levonovyi-github-deploy-policy"
  user = aws_iam_user.github_deployer.name

  policy = jsonencode({
    Version = "2012-10-17"

    Statement = [
      {
        Effect = "Allow"
        Action = [
          "ecr:GetAuthorizationToken"
        ]
        Resource = "*"
      },
      {
        Effect = "Allow"
        Action = [
          "ecr:BatchCheckLayerAvailability",
          "ecr:CompleteLayerUpload",
          "ecr:InitiateLayerUpload",
          "ecr:PutImage",
          "ecr:UploadLayerPart"
        ]
        Resource = aws_ecr_repository.api.arn
      },
      {
        Effect = "Allow"
        Action = [
          "ecs:DescribeTaskDefinition",
          "ecs:RegisterTaskDefinition",
          "ecs:DescribeServices",
          "ecs:UpdateService"
        ]
        Resource = "*"
      },
      {
        Effect = "Allow"
        Action = [
          "iam:PassRole"
        ]
        Resource = aws_iam_role.ecs_execution.arn
      }
    ]
  })
}
