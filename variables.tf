variable "aws_region" {
  description = "AWS region for the production stack."
  type        = string
  default     = "eu-west-2"
}

variable "project_name" {
  type        = string
  default     = "re-prod"
}

variable "environment" {
  type        = string
  default     = "production"
}

variable "vpc_cidr" {
  type    = string
  default = "10.40.0.0/16"
}

variable "availability_zones" {
  description = "Use three AZs available in the selected region."
  type        = list(string)
  default     = ["eu-west-2a", "eu-west-2b", "eu-west-2c"]
}

variable "jenkins_instance_type" {
  type    = string
  default = "t3.large"
}

variable "jenkins_volume_size" {
  type    = number
  default = 50
}

variable "eks_version" {
  description = "Choose a Kubernetes version currently supported by EKS in this region."
  type        = string
  default     = "1.32"
}

variable "eks_node_instance_types" {
  type    = list(string)
  default = ["t3.large"]
}

variable "eks_node_min_size" {
  type    = number
  default = 2
}

variable "eks_node_desired_size" {
  type    = number
  default = 2
}

variable "eks_node_max_size" {
  type    = number
  default = 4
}

variable "jenkins_ami_id" {
  description = "Optional pinned Ubuntu 24.04 AMI ID for eu-west-2. Leave blank to resolve Canonical's current AMI via SSM."
  type        = string
  default     = ""
}

variable "tags" {
  type    = map(string)
  default = {}
}
