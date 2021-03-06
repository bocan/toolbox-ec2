output "ssh_key" {
  description = "ssh key generated by terraform"
  sensitive   = true
  value       = tls_private_key.the_key.private_key_pem
}

output "public_address" {
  description = "public ip address of the instance"
  value       = module.ec2_instance.public_ip
}
