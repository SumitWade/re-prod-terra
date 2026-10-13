output "jenkins_role_arn" { value = aws_iam_role.jenkins.arn }
output "jenkins_instance_profile_name" { value = aws_iam_instance_profile.jenkins.name }
output "eks_node_role_arn" { value = aws_iam_role.eks_node.arn }
