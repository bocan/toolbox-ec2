
locals {

  name = "chrisfu-support"
  your_ip = "31.121.189.242"

  vpc           = "vpc-041eae251015f69cc"
  subnet_id     = "subnet-0297c5f655e0c061e"
  instance_type = "t3.medium"

  user_data = <<-EOT
  #!/bin/bash
  yum install -y postgresql nmap
  yum install -y https://s3.amazonaws.com/ec2-downloads-windows/SSMAgent/latest/linux_amd64/amazon-ssm-agent.rpm
  EOT

  tags = {
    Owner       = "Chris Funderburg"
    Terraform   = "true"
    Environment = "support"
  }
}
