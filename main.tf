locals {
  name = "${var.project_name}-${var.environment}"
  common_tags = merge(var.tags, {
    Project     = var.project_name
    Environment = var.environment
    ManagedBy   = "Terraform"
  })
}

module "network" {
  source = "./modules/network"

  name               = local.name
  vpc_cidr           = var.vpc_cidr
  availability_zones = var.availability_zones
  tags               = local.common_tags
}

module "jenkins_iam" {
  source = "./modules/jenkins-iam"

  name        = "${local.name}-jenkins"
  aws_region  = var.aws_region
  account_id  = data.aws_caller_identity.current.account_id
  ecr_repos   = ["re-be", "re-fe"]
  tags        = local.common_tags
}

module "ecr" {
  source = "./modules/ecr"

  repository_names = ["re-be", "re-fe"]
  tags             = local.common_tags
}

module "eks" {
  source = "./modules/eks"

  name                    = "${local.name}-eks"
  kubernetes_version      = var.eks_version
  vpc_id                  = module.network.vpc_id
  private_subnet_ids      = module.network.private_subnet_ids
  node_role_arn           = module.jenkins_iam.eks_node_role_arn
  jenkins_role_arn        = module.jenkins_iam.jenkins_role_arn
  jenkins_security_group_id = module.jenkins.security_group_id
  node_instance_types     = var.eks_node_instance_types
  node_min_size           = var.eks_node_min_size
  node_desired_size       = var.eks_node_desired_size
  node_max_size           = var.eks_node_max_size
  tags                    = local.common_tags
}

module "jenkins" {
  source = "./modules/jenkins"

  name                 = "${local.name}-jenkins"
  vpc_id               = module.network.vpc_id
  private_subnet_id    = module.network.private_subnet_ids[0]
  instance_type        = var.jenkins_instance_type
  root_volume_size     = var.jenkins_volume_size
  instance_profile     = module.jenkins_iam.jenkins_instance_profile_name
  ami_id               = var.jenkins_ami_id
  tags                 = local.common_tags
}

data "aws_caller_identity" "current" {}
