# toolbox-ec2
A bit of Terraform to create a support AWS EC2 instnace in your VPC

## Instructions

1. How you connect to AWS is your problem.  I use 'awsp' and just choose a profile, do a ```aws sso login``` and I'm away.
2. This saves state locally.  There's no need for anything else as it's not assumed you're collaborating on it with anyone else, and you just want a *temporary* EC2 instance to use as a jump box.
3. Edit the locals.tf file.  Change 'name' to whatever you want your resources called, your_ip to your ip, the vpc and subnet_id to one in your existing VPC, and add anything you want installed into the user_data.  You should also tweak the tags unless your name is the same as mine.

## Terraform Version Support
This was built and tested with Terraform 1.0.11 as that was the version I supported at the time.


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
