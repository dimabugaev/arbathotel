#PROD MANIFEST

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.27"
    }
  }

  backend "s3" {
    bucket  = "arbat-hotel-terraform-state"
    key     = "prod_terraform.tfstate"
    region  = "eu-central-1"
    profile = "arbathotelserviceterraformuser"
  }

  required_version = ">= 1.2.0"
}

provider "aws" {
  region  = "eu-central-1"
  profile = "arbathotelserviceterraformuser"
}

module "environment" {
  source                 = "../tf_modules/base_environment/"
  environment            = "prod"
  reports_email          = var.reports_email
  reports_email_password = var.reports_email_password
}
