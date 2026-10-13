module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "20.37.1"

  cluster_name    = var.name
  cluster_version = var.kubernetes_version

  vpc_id     = var.vpc_id
  subnet_ids = var.private_subnet_ids

  # Private-only endpoint: reach the Kubernetes API from the VPC / Jenkins.
  cluster_endpoint_private_access = true
  cluster_endpoint_public_access  = false

  cluster_security_group_additional_rules = {
    ingress_jenkins_to_private_api = {
      description              = "Allow Jenkins EC2 to reach the private EKS Kubernetes API"
      protocol                 = "tcp"
      from_port                = 443
      to_port                  = 443
      type                     = "ingress"
      source_security_group_id = var.jenkins_security_group_id
    }
  }

  enable_cluster_creator_admin_permissions = false

  cluster_addons = {
    coredns = {
      most_recent = true
    }
    kube-proxy = {
      most_recent = true
    }
    vpc-cni = {
      most_recent = true
    }
    eks-pod-identity-agent = {
      most_recent = true
    }
  }

  eks_managed_node_groups = {
    default = {
      name           = "${var.name}-nodes"
      instance_types = var.node_instance_types
      min_size       = var.node_min_size
      desired_size   = var.node_desired_size
      max_size       = var.node_max_size
      subnet_ids     = var.private_subnet_ids
      create_iam_role = false
      iam_role_arn    = var.node_role_arn
      capacity_type  = "ON_DEMAND"
      labels = {
        workload = "general"
      }
    }
  }

  access_entries = {
    jenkins = {
      principal_arn = var.jenkins_role_arn
      policy_associations = {
        production_admin = {
          policy_arn = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSAdminPolicy"
          access_scope = {
            type       = "namespace"
            namespaces = ["production"]
          }
        }
      }
    }
  }

  tags = var.tags
}
