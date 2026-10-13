data "aws_ssm_parameter" "ubuntu_ami" {
  count = var.ami_id == "" ? 1 : 0
  name  = "/aws/service/canonical/ubuntu/server/24.04/stable/current/amd64/hvm/ebs-gp3/ami-id"
}

resource "aws_security_group" "jenkins" {
  name        = "${var.name}-sg"
  description = "Jenkins EC2: no inbound ports; access through AWS Systems Manager Session Manager."
  vpc_id      = var.vpc_id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Outbound updates and AWS APIs via NAT"
  }

  tags = var.tags
}

resource "aws_instance" "jenkins" {
  ami                         = var.ami_id != "" ? var.ami_id : data.aws_ssm_parameter.ubuntu_ami[0].value
  instance_type               = var.instance_type
  subnet_id                   = var.private_subnet_id
  vpc_security_group_ids      = [aws_security_group.jenkins.id]
  iam_instance_profile        = var.instance_profile
  associate_public_ip_address = false

  root_block_device {
    volume_type           = "gp3"
    volume_size           = var.root_volume_size
    encrypted             = true
    delete_on_termination = false
  }

  metadata_options {
    http_endpoint = "enabled"
    http_tokens   = "required"
  }

  user_data = <<-EOF
    #!/bin/bash
    set -euxo pipefail
    apt-get update
    DEBIAN_FRONTEND=noninteractive apt-get install -y \
      fontconfig openjdk-21-jre docker.io unzip curl git
    systemctl enable --now docker
    # Install Jenkins from the official Jenkins apt repository using the
    # current documented signing-key procedure after instance provisioning.
    # Keep Jenkins installation/configuration in a reviewed AMI or bootstrap.
  EOF

  user_data_replace_on_change = true

  tags = merge(var.tags, {
    Name = var.name
  })

  lifecycle {
    ignore_changes = [ami]
  }
}
