terraform {
  required_version = "~> 1.9.3"
  required_providers {
    aws = {
        source = "hashicorp/aw"
        version = "~> 5.49.0"
    }
  }

  backend "s3" {   
    bucket = "backend-terraform-eks"
    region = var.region
    key = "eks/terraform.tfstate"
    dynamodb_table = "Lock-Files"
    encrypt = true
  }
}

provider "aws" {
  region = var.region
}