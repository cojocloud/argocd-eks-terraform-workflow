terraform {
  required_version = "~> 1.13.3"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.49.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "2.31.0"
    }
  }
  backend "s3" {
    bucket       = "YOUR_S3_BUCKET_NAME"
    region       = "us-east-1"
    key          = "EKS-ArgoCD-AWS-LB-Controller-Terraform/vpc-ec2.tfstate"
    use_lockfile = true
    encrypt      = true
  }
}

provider "aws" {
  region = var.aws-region
}