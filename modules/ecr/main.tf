module "repositories" {
  for_each = toset(var.repository_names)

  source  = "terraform-aws-modules/ecr/aws"
  version = "2.4.0"

  repository_name                 = each.value
  repository_type                 = "private"
  repository_image_tag_mutability = "IMMUTABLE"
  repository_image_scan_on_push   = true

  create_lifecycle_policy = true
  repository_lifecycle_policy = jsonencode({
    rules = [
      {
        rulePriority = 1
        description  = "Keep the latest 30 images"
        selection = {
          tagStatus   = "any"
          countType   = "imageCountMoreThan"
          countNumber = 30
        }
        action = { type = "expire" }
      }
    ]
  })

  tags = var.tags
}
