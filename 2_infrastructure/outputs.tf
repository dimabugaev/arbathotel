output "db_instance_address" {
  description = "The address of the RDS instance"
  value       = module.db.db_instance_address
}

output "db_instance_port" {
  description = "The database port"
  value       = module.db.db_instance_port
}

output "db_instance_username" {
  description = "The master username for the database"
  value       = module.db.db_instance_username
  sensitive   = true
}

output "db_instance_password" {
  description = "The database password (this password may be old, because Terraform doesn't track it after initial creation)"
  value       = module.db.db_instance_password
  sensitive   = true
}

# psql -h $(terraform output -raw db_instance_address) -p $(terraform output -raw db_instance_port) \ 
# -U $(terraform output -raw db_instance_username) -W $(terraform output -raw db_instance_password) postgres