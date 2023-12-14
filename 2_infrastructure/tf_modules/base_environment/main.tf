#ENVIRONMANT MANIFEST

data "terraform_remote_state" "common" {
  backend = "s3"
  config = {
    bucket  = var.common_bucket_name
    region  = var.aws_region
    key     = var.common_bucket_key
    profile = var.aws_profile
  }
}

locals {
  tags = {
    Name        = "${var.environment}services"
    Environment = var.environment
    Terraform   = "true"
  }

  prefixname = var.environment == "dev" ? "develop" : var.environment == "prod" ? "productive" : file("[Error] this module should only be ran for stages ['prod' or 'dev' ]")

}
