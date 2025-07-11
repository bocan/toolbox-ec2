provider "aws" {
  region = local.region
}

# A security group to allow ssh (or other) access.
resource "aws_security_group" "ingress-ssh" {
  #checkov:skip=CKV2_AWS_5:False positive. This is attached via a module and checkov can't detect it.
  #checkov:skip=CKV_AWS_382:Purposeful decision.
  name        = "${local.name}-allow-ssh-sg"
  vpc_id      = data.aws_vpc.selected.id
  description = "Allow ssh"
  ingress {
    description = "Allow inbound traffic to SSH from JUST you"
    cidr_blocks = [
      "${local.your_ip}/32"
    ]
    from_port = 22
    to_port   = 22
    protocol  = "tcp"
  }
  egress {
    description = "Allow outbound traffic to anything"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    #tfsec:ignore:aws-vpc-no-public-egress-sgr
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# All the gubbins to setup a quick access key
resource "tls_private_key" "the_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "generated_key" {
  key_name   = local.name
  public_key = tls_private_key.the_key.public_key_openssh
}

resource "local_file" "ssh_key" {
  filename = "${aws_key_pair.generated_key.key_name}.pem"
  content  = tls_private_key.the_key.private_key_pem
}

# Ya boi. This is what we're here for.
module "ec2" {
  #checkov:skip=CKV_TF_1:Stupid Check
  source  = "terraform-aws-modules/ec2-instance/aws"
  version = "~> 5.8.0"

  name = local.name

  ami                         = data.aws_ami.amazon-linux-2023.id
  instance_type               = local.instance_type
  key_name                    = aws_key_pair.generated_key.key_name
  monitoring                  = true
  vpc_security_group_ids      = [aws_security_group.ingress-ssh.id]
  subnet_id                   = local.subnet_id
  associate_public_ip_address = local.public_ip

  create_iam_instance_profile = true
  iam_role_description        = "IAM role for EC2 Support instance"
  iam_role_policies = {
    AmazonSSMManagedInstanceCore = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
  }

  ami_ssm_parameter = "/aws/service/ami-amazon-linux-latest/al2023-ami-kernel-6.1-x86_64"

  user_data_base64 = base64encode(local.user_data)

  metadata_options = {
    http_endpoint               = "enabled"
    http_tokens                 = "required"
    http_put_response_hop_limit = 8
    instance_metadata_tags      = "enabled"
  }

  enable_volume_tags = true
  root_block_device = [
    {
      encrypted   = true
      volume_type = "gp3"
    },
  ]

  tags = {
    Terraform   = "true"
    Environment = "support"
  }
}


module "vpc_endpoints" {
  #checkov:skip=CKV_TF_1:Stupid Check
  source  = "terraform-aws-modules/vpc/aws//modules/vpc-endpoints"
  version = "~> 5.19.0"

  vpc_id = data.aws_vpc.selected.id

  endpoints = { for service in toset(["ssm", "ssmmessages", "ec2messages"]) :
    replace(service, ".", "_") =>
    {
      service             = service
      subnet_ids          = [local.subnet_id]
      private_dns_enabled = true
      tags                = { Name = "${local.name}-${service}" }
    }
  }

  create_security_group      = true
  security_group_name_prefix = "${local.name}-vpc-endpoints-"
  security_group_description = "VPC endpoint security group"
  security_group_rules = {
    ingress_https = {
      description = "HTTPS from subnets"
      cidr_blocks = [data.aws_vpc.selected.cidr_block]
    }
  }

  tags = {
    Terraform   = "true"
    Environment = "support"
  }
}
