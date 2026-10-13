# re-be + re-fe production AWS infrastructure (Terraform modules)

This stack provisions:
- VPC with public/private subnets across 3 AZs and one NAT gateway (cost-conscious, not AZ-resilient NAT).
- Private EKS endpoint and EKS managed nodes in private subnets.
- ECR repositories `re-be` and `re-fe`, immutable image tags, scan-on-push, lifecycle retention.
- Jenkins EC2 in a private subnet with encrypted gp3 EBS, IMDSv2, no inbound ports, SSM role.
- Jenkins IAM role with ECR push access limited to the two repositories and EKS describe permission.
- EKS access entry granting Jenkins EKS admin policy scoped to namespace `production`.

## Important pre-apply checks

1. Confirm the AWS account and `eu-west-2` region.
2. Confirm `eks_version` is currently supported by EKS in the chosen region.
3. The default EKS endpoint is private-only. Run `kubectl` from Jenkins/inside the VPC or use a VPN/SSM-enabled admin host.
4. The Jenkins EC2 bootstrap installs Java and Docker only. It intentionally does NOT install/configure Jenkins or its plugins; bake Jenkins into a reviewed AMI or complete the official Jenkins installation and hardening before use.
5. The EKS cluster security group allows HTTPS from the Jenkins EC2 security group to the private Kubernetes API. The Jenkins EC2 IAM role is granted namespace-scoped EKS admin permissions for the `production` namespace. This is still powerful; for mature production, replace it with a dedicated Kubernetes Role/RoleBinding for only the required Deployments, Services, ConfigMaps and Helm-managed resources. Helm may require additional permissions depending on chart resources.
7. AWS Load Balancer Controller, ACM, DNS, Secrets Manager secret synchronization, Atlas networking and MongoDB credentials are intentionally not created here; see the next steps below.
8. The default single NAT gateway saves money but creates an AZ-level egress dependency. For stricter production resilience, use one NAT gateway per AZ and budget accordingly.
9. Use an S3 remote state backend with encryption, versioning and locking. Do not commit state or `terraform.tfvars`.

## Usage

```bash
cp terraform.tfvars.example terraform.tfvars
# Edit values; check supported EKS version and AMI.

terraform init
terraform fmt -recursive
terraform validate
terraform plan -out=tfplan
terraform show tfplan
terraform apply tfplan
```

Never apply without reviewing the plan and confirming the AWS account.

## Jenkins access

Once Jenkins is installed and the instance is registered with SSM, run the generated `jenkins_ssm_port_forward_command` output from an AWS-authenticated workstation with Session Manager plugin installed, then open `http://localhost:8080`. For production, terminate TLS through an internal ALB/reverse proxy and restrict administrative access.

## Next production tasks

- Install and configure Jenkins using official documentation, secure admin users, disable anonymous access, install only required plugins, configure backups and controller/agent separation.
- Install AWS Load Balancer Controller with its dedicated IAM role and Helm chart.
- Create `production` namespace using an admin bootstrap identity, then verify Jenkins's EKS access entry.
- Create an AWS Secrets Manager secret for the MongoDB Atlas URI; allow only the backend workload identity to read it. Do not place Atlas credentials in Terraform variables, Terraform state, Docker build args, Git or frontend `NEXT_PUBLIC_*` variables.
- Configure Atlas network access via private connectivity (e.g. AWS PrivateLink where appropriate) or tightly restricted egress/IP access.
- Add separate Kubernetes Helm charts, resource requests/limits, probes that use real health endpoints, PodDisruptionBudgets, topology spread constraints and smoke tests.
- Configure ALB/ACM/Route 53, CloudWatch alarms/logs, backups and restore testing.
- Consider EKS node autoscaling and Metrics Server before enabling HPA.
- Review AWS costs: NAT Gateway, EKS control plane, EC2 nodes, EBS, ALB, data transfer and logging are billable.
