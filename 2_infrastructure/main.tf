terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.16"
    }
  }

  required_version = ">= 1.2.0"
}

data "aws_availability_zones" "available" {
  state = "available"
}

locals {
  name    = "dev"
  region  = "eu-central-1"

  azs      = slice(data.aws_availability_zones.available.names, 0, 2)

  tags = {
    Name       = local.name
    Environment    = local.name
    Terraform = "true"
  }
}

provider "aws" {
  region  = local.region
  profile = var.aws_profile
}

#VPS + Subnets

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "2.77.0"

  name                 = local.name
  cidr                 = "192.168.0.0/16"
  azs                  = local.azs
  public_subnets       = ["192.168.1.0/24", "192.168.2.0/24"]
  private_subnets       = ["192.168.11.0/24", "192.168.12.0/24"] 
  database_subnets       = ["192.168.21.0/24", "192.168.22.0/24"]

  enable_dns_hostnames = true
  enable_dns_support   = true
  
  create_database_subnet_group = true
  create_database_subnet_route_table     = true
  create_database_internet_gateway_route = true

  tags = local.tags
}

#SG for DB

module "security_group" {
   source  = "terraform-aws-modules/security-group/aws"
   version = "~> 4.0"

   name        = local.name
   description = "PostgreSQL security group"
   vpc_id      = module.vpc.vpc_id

   # ingress
   ingress_with_cidr_blocks = [
     {
       from_port   = 5432
       to_port     = 5432
       protocol    = "tcp"
       description = "PostgreSQL access from ALL"
       cidr_blocks = "0.0.0.0/0"
     },
    ]
    tags = local.tags
}

#RDS

module "db" {
  source = "terraform-aws-modules/rds/aws"

  identifier = local.name

  # All available versions: https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/CHAP_PostgreSQL.html#PostgreSQL.Concepts
  engine               = "postgres"
  engine_version       = "14.6"
  family               = "postgres14" # DB parameter group
  major_engine_version = "14.6"       # DB option group
  instance_class       = "db.t3.micro"

  allocated_storage     = 20
  max_allocated_storage = 100

  # NOTE: Do NOT use 'user' as the value for 'username' as it throws:
  # "Error creating DB Instance: InvalidParameterValue: MasterUsername
  # user cannot be used as it is a reserved word used by the engine"
  db_name  = "dev_arbathotel"
  username = "dev"

  create_random_password = false
  password = var.db_password
  port     = 5432

  multi_az               = false
  db_subnet_group_name   = module.vpc.database_subnet_group
  vpc_security_group_ids = [module.security_group.security_group_id]
  publicly_accessible = true

#   maintenance_window              = "Mon:00:00-Mon:03:00"
#   backup_window                   = "03:00-06:00"
#   enabled_cloudwatch_logs_exports = ["postgresql", "upgrade"]
#   create_cloudwatch_log_group     = true

  backup_retention_period = 7
  skip_final_snapshot     = true
  deletion_protection     = false

  performance_insights_enabled          = true
  performance_insights_retention_period = 7
#   create_monitoring_role                = true
#   monitoring_interval                   = 60
#   monitoring_role_name                  = "example-monitoring-role-name"
#   monitoring_role_use_name_prefix       = true
#   monitoring_role_description           = "Description for monitoring role"

  parameters = [
    {
      name  = "autovacuum"
      value = 1
    },
    {
      name  = "client_encoding"
      value = "utf8"
    }
  ]

  tags = local.tags
}
