#COMMON MANIFEST

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.16"
    }
  }

  backend "s3" {
    bucket  = "arbat-hotel-terraform-state"
    key     = "common_terraform.tfstate"
    region  = "eu-central-1"
    profile = "arbathotelserviceterraformuser"
  }

  required_version = ">= 1.2.0"
}

provider "aws" {
  region  = var.aws_region
  profile = var.aws_profile
}

data "aws_availability_zones" "available" {
  state = "available"
}

locals {
  tags = {
    Name        = "common services"
    Environment = "common"
    Terraform   = "true"
  }
}
