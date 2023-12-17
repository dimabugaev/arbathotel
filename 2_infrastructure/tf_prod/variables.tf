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

variable "reports_email" {
  description = "email address for income reports data"
  type        = string
  sensitive   = true
}

variable "reports_email_password" {
  description = "email password for income reports email"
  type        = string
  sensitive   = true
}