#PROD MANIFEST

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.16"
    }
  }

  backend "s3" {
    bucket = "arbat-hotel-terraform-state"
    key    = "prod_terraform.tfstate"
    region = "eu-central-1"
    profile = "arbathotelserviceterraformuser"
  }

  required_version = ">= 1.2.0"
}

provider "aws" {
  region  = "eu-central-1"
  profile = "arbathotelserviceterraformuser"
}