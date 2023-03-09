# variable "region" {
#   description = "Region for AWS resources."
#   default = "eu-central-1"
#   type = string
# }

variable "aws_profile" {
  description = "Profile for AWS connect."
  default = "arbathotelserviceterraformuser"
  type = string
}

variable "db_password" {
  description = "RDS root user password"
  type        = string
  sensitive   = true
}
