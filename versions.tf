terraform {
  # Tested with OpenTofu 1.10.2
  required_version = ">= 1.10.2"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 6.2.0"
    }
  }
}
