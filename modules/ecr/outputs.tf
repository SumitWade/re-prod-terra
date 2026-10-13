output "repository_urls" {
  value = { for name, repo in module.repositories : name => repo.repository_url }
}
