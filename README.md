[![tfsec](https://github.com/bocan/toolbox-ec2/actions/workflows/tfsec.yml/badge.svg)](https://github.com/bocan/toolbox-ec2/actions/workflows/tfsec.yml)

# toolbox-ec2
This is a bit of Terraform to create a support AWS EC2 instance in your VPC with a **public** address.  You can use this as a temporary jump box or bastion to perhaps run a query against your database, connect to a non-public EKS cluster, etc.

It's an Amazon 2023 instance with the following tools installed:

* Git
* Helm.
* Kubectl.
* Nmap
* The Postgresql client.

*A word of warning*: This thing is quite safe as you can only connect via your local IP address, and of course it requires the key anyway - however, if you're building it in your company's AWS account, please ensure you have permission to create entities with public addresses on the public subnets.

## Instructions

1. It's assumed you're a Terraform or Tofu user already, so how you connect to AWS is your problem.
2. This saves state locally.  There's no need for anything else as it's not assumed you're collaborating on it with anyone else, and you just want a *temporary* EC2 instance to use as a jump box / bastion.
3. Edit the locals.tf file.  Change 'name' to whatever you want your resources called, your_ip to your IP address, the VPC and a *public* subnet_id to one in your existing VPC, and add anything you want installed into the user_data.  You should also tweak the tags unless your name is the same as mine.

## Customisation

* If you have network access to whichever AWS network you're building this in, you could just choose a private subnet.

* If you *really* want ssh access from anywhere, you could tell it your address is 0.0.0.0 - but, the network prefix is purposely hard-coded to /32.  You'd need to change that too.

## Tofu Version Support
This was built and tested with OpenTofu v1.9.0.
