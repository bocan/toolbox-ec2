locals {

  name    = "chrisfu-test"
  your_ip = "5.71.73.237"

  vpc           = "vpc-07104ae35cfeab540"
  region        = "eu-west-1"
  instance_type = "t3.nano"

  # An important choice here... SSM IS enabled so go internal if you can.
  # subnet_id     = "subnet-0c4539b4bada1b8f4" # a private one.
  # public_ip     = false
  subnet_id = "subnet-067c33d7fe2fa663d" # a public one.
  public_ip = false

  # Todo: Template this w/ versions
  user_data = file("${path.module}/user_data.sh")

  tags = {
    Owner       = "Chris Funderburg"
    Terraform   = "true"
    Environment = "support"
  }
}
