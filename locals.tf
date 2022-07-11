locals {

  name    = "chrisfu-support"
  your_ip = "188.223.70.12"

  vpc           = "vpc-041eae251015f69cc"
  subnet_id     = "subnet-0297c5f655e0c061e"
  instance_type = "t3.medium"

  # Todo: Template this w/ versions
  user_data = file("${path.module}/user_data.sh")

  tags = {
    Owner       = "Chris Funderburg"
    Terraform   = "true"
    Environment = "support"
  }
}
