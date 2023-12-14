variable "aws_profile" {
  description = "Profile for AWS connect."
  default = "arbathotelserviceterraformuser"
  type = string
}

variable "aws_region" {
   description = "Region for AWS resources."
   default = "eu-central-1"
   type = string
}

variable "arbat_pub_key" {
  description = "Public key for SSH nat"
  type = string
  sensitive = true
}


