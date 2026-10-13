variable "name" { type = string }
variable "aws_region" { type = string }
variable "account_id" { type = string }
variable "ecr_repos" { type = list(string) }
variable "tags" { type = map(string) }
