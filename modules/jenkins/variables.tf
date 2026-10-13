variable "name" { type = string }
variable "vpc_id" { type = string }
variable "private_subnet_id" { type = string }
variable "instance_type" { type = string }
variable "root_volume_size" { type = number }
variable "instance_profile" { type = string }
variable "ami_id" { type = string }
variable "tags" { type = map(string) }
