output "vpc_id" {
  value = module.network.vpc_id
}

output "public_subnet_ids" {
  value = module.network.public_subnet_ids
}

output "private_subnet_ids" {
  value = module.network.private_subnet_ids
}

output "eks_cluster_name" {
  value = module.eks.cluster_name
}

output "eks_cluster_endpoint" {
  value     = module.eks.cluster_endpoint
  sensitive = true
}

output "ecr_repository_urls" {
  value = module.ecr.repository_urls
}

output "jenkins_instance_id" {
  value = module.jenkins.instance_id
}

output "jenkins_private_ip" {
  value = module.jenkins.private_ip
}

output "jenkins_ssm_port_forward_command" {
  value = "aws ssm start-session --target ${module.jenkins.instance_id} --document-name AWS-StartPortForwardingSession --parameters '{\"portNumber\":[\"8080\"],\"localPortNumber\":[\"8080\"]}' --region ${var.aws_region}"
  description = "Run this from an AWS-authenticated workstation with Session Manager plugin installed, then open http://localhost:8080."
}
