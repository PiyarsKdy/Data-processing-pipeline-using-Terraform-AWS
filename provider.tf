#Terraform Block
terraform {
  required_version = "1.8.1"
   required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = "us-east-1"
  profile = "default"
}


