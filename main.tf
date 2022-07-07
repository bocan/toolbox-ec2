
# A security group to allow ssh (or other) access.
resource "aws_security_group" "ingress-ssh" {
  #checkov:skip=CKV2_AWS_5:False positive. This is attached via a module and checkov can't detect it.
  name        = "${local.name}-allow-ssh-sg"
  vpc_id      = data.aws_vpc.selected.id
  description = "Allow ssh"
  ingress {
    description = "Allow inbound traffic to SSH from anywhere"
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

# Create EC2 Instance Role to allow SSM access
resource "aws_iam_role" "ssm_role" {
  name_prefix = "ssm_role-"
  path        = "/"
  tags        = local.tags

  assume_role_policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Action": "sts:AssumeRole",
            "Principal": {
               "Service": "ec2.amazonaws.com"
            },
            "Effect": "Allow",
            "Sid": ""
        }
    ]
}
EOF
}

resource "aws_iam_instance_profile" "ssm_inst_profile" {
  name = "ssm_inst_profile"
  role = aws_iam_role.ssm_role.name
}

resource "aws_iam_role_policy_attachment" "SSM-role-policy-attach" {
  role       = aws_iam_role.ssm_role.name
  policy_arn = data.aws_iam_policy.AmazonSSMManagedInstanceCore.arn
}

# Ya boi. This is what we're here for.
module "ec2_instance" {
  source  = "terraform-aws-modules/ec2-instance/aws"
  version = "~> 3.0"

  name = local.name

  ami                         = data.aws_ami.amazon-linux-2.id
  instance_type               = local.instance_type
  key_name                    = aws_key_pair.generated_key.key_name
  monitoring                  = true
  vpc_security_group_ids      = [aws_security_group.ingress-ssh.id]
  subnet_id                   = local.subnet_id
  associate_public_ip_address = true
  iam_instance_profile        = aws_iam_instance_profile.ssm_inst_profile.name

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

