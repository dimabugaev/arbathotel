#DEV MANIFEST

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.27"
    }
  }

  backend "s3" {
    bucket  = "arbat-hotel-terraform-state"
    key     = "dev_terraform.tfstate"
    region  = "eu-central-1"
    profile = "arbathotelserviceterraformuser"
  }

  required_version = ">= 1.2.0"
}

provider "aws" {
  region  = var.aws_region
  profile = var.aws_profile
}

module "environment" {
  source                 = "../tf_modules/base_environment/"
  environment            = "dev"
  reports_email          = var.reports_email
  reports_email_password = var.reports_email_password
}
