variable "aws_profile" {
  description = "Profile for AWS connect."
  default     = "arbathotelserviceterraformuser"
  type        = string
}

variable "aws_region" {
  description = "Region for AWS resources."
  default     = "eu-central-1"
  type        = string
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

#terraform common satate
variable "common_bucket_name" {
  description = "Name of bucket with common manifest"
  default     = "arbat-hotel-terraform-state"
  type        = string
}

variable "common_bucket_key" {
  description = "Key of bucket with common manifest"
  default     = "common_terraform.tfstate"
  type        = string
}

#set for each enviroment
variable "buildpath" {
  description = "Path to built sources catalog"
  default     = "./../build/"
  type        = string
}

variable "environment" {
  description = "Type of environment" #dev prod 
  type        = string
}


#==LAMBDA SOURCES PATHS
#==BNOVO
variable "extract_bnovo_data_zip" {
  description = "Name pakage"
  default     = "extract_bnovo_data.zip"
  type        = string
}

variable "extract_bnovo_invoices_zip" {
  description = "Name pakage"
  default     = "extract_bnovo_invoices.zip"
  type        = string
}

variable "extract_bnovo_finance_zip" {
  description = "Name pakage"
  default     = "extract_bnovo_finance.zip"
  type        = string
}

variable "extract_bnovo_booking_zip" {
  description = "Name pakage"
  default     = "extract_bnovo_booking.zip"
  type        = string
}

variable "to_plan_extract_bnovo_fin_zip" {
  description = "Name pakage"
  default     = "to_plan_extract_bnovo_fin.zip"
  type        = string
}

variable "to_plan_extract_bnovo_booking_zip" {
  description = "Name pakage"
  default     = "to_plan_extract_bnovo_booking.zip"
  type        = string
}

variable "extract_bnovo_guests_zip" {
  description = "Name pakage"
  default     = "extract_bnovo_guests.zip"
  type        = string
}

variable "extract_bnovo_ufms_zip" {
  description = "Name pakage"
  default     = "extract_bnovo_ufms.zip"
  type        = string
}

variable "to_plan_extract_frequently_bnovo_zip" {
  description = "Name pakage"
  default     = "to_plan_extract_frequently_bnovo.zip"
  type        = string
}

#===
#==ECS
variable "run_dbt_task_zip" {
  description = "Name pakage"
  default     = "run_dbt_task.zip"
  type        = string
}

variable "run_soap_task_zip" {
  description = "Name pakage"
  default     = "run_soap_task.zip"
  type        = string
}
#==BANKS
variable "to_plan_extract_psb_zip" {
  description = "Name pakage"
  default     = "to_plan_extract_psb.zip"
  type        = string
}

variable "to_plan_extract_tinkoff" {
  description = "Name pakage"
  default     = "to_plan_extract_tinkoff.zip"
  type        = string
}

variable "to_plan_extract_alfa" {
  description = "Name pakage"
  default     = "to_plan_extract_alfa.zip"
  type        = string
}

variable "extract_tinkoff_account_zip" {
  description = "Name pakage"
  default     = "extract_tinkoff_account.zip"
  type        = string
}

variable "extract_alfa_account_zip" {
  description = "Name pakage"
  default     = "extract_alfa_account.zip"
  type        = string
}

variable "extract_email_reports_data_zip" {
  description = "Name pakage"
  default     = "extract_email_reports_data.zip"
  type        = string
}

variable "upload_psb_acquiring_zip" {
  description = "Name pakage"
  default     = "upload_psb_acquiring.zip"
  type        = string
}

variable "upload_ucb_account_zip" {
  description = "Name pakage"
  default     = "upload_ucb_account.zip"
  type        = string
}
#==API
variable "employees_reports_zip" {
  description = "Name pakage"
  default     = "employees_reports_data.zip"
  type        = string
}

variable "dict_operate_zip" {
  description = "Name pakage"
  default     = "dict_operate_data.zip"
  type        = string
}

variable "api_report_bnovo_zip" {
  description = "Name pakage"
  default     = "api_report_bnovo.zip"
  type        = string
}
