output "vpc_id" {
  value = module.vpc.vpc_id
}

output "public_subnets" {
  value = module.vpc.public_subnets  
}

output "private_subnets" {
  value = module.vpc.private_subnets  
}

output "sg_access_to_secretsmanager" {
  value = module.secretsmanager_access_security_group.security_group_id
}

output "database_subnet_group" {
  value = aws_db_subnet_group.default.id
}

#This group for inbound  
output "sg_ssh_proxy" {
  value = module.nat.sg_id
}