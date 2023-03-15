terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.16"
    }
  }

  backend "s3" {
    bucket = "arbat-hotel-terraform-state-dev"
    key    = "network/terraform.tfstate"
    region = "eu-central-1"
    profile = "arbathotelserviceterraformuser"
  }

  required_version = ">= 1.2.0"
}

data "aws_availability_zones" "available" {
  state = "available"
}

locals {
  name    = "dev"
  region  = "eu-central-1"
  lamdba_reports_name = "dev-reports-emploeeys-operations"
  employees_reports_zip = "./build/employees_reports_data.zip"

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

module "rds_security_group" {
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
  vpc_security_group_ids = [module.rds_security_group.security_group_id]
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


#lambda

module "lambda_function_employees_reports" {
  source  = "terraform-aws-modules/lambda/aws"
  version = "~> 2.0"

  function_name =  "${local.lamdba_reports_name}-lambda"
  description   = "lambda function for support to work operations reports"
  handler       = "employees_reports_data.lambda_handler"
  runtime       = "python3.8"

  publish = true

  create_package         = false
  local_existing_package = local.employees_reports_zip

  attach_network_policy  = true

#  attach_policy = true
#  policy        = "arn:aws:iam::aws:policy/AmazonRDSDataFullAccess"

# example policy
#   attach_policy_jsons = true
#   policy_jsons = [
#     <<-EOT
#       {
#           "Version": "2012-10-17",
#           "Statement": [
#               {
#                   "Effect": "Allow",
#                   "Action": [
#                       "xray:*"
#                   ],
#                   "Resource": ["*"]
#               }
#           ]
#       }
#     EOT
#   ]
#   number_of_policy_jsons = 1

#   attach_policy = true
#   policy        = "arn:aws:iam::aws:policy/AmazonRDSDataFullAccess"

#   attach_policies    = true
#   policies           = ["arn:aws:iam::aws:policy/AWSXrayReadOnlyAccess"]
#   number_of_policies = 1

#   attach_policy_statements = true
#   policy_statements = {
#     dynamodb = {
#       effect    = "Allow",
#       actions   = ["dynamodb:BatchWriteItem"],
#       resources = ["arn:aws:dynamodb:eu-west-1:052212379155:table/Test"]
#     },
#     s3_read = {
#       effect    = "Deny",
#       actions   = ["s3:HeadObject", "s3:GetObject"],
#       resources = ["arn:aws:s3:::my-bucket/*"]
#     }
#   }


  vpc_subnet_ids         = module.vpc.private_subnets
  vpc_security_group_ids = [module.lambda_security_group.security_group_id]

  allowed_triggers = {
    AllowExecutionFromAPIGateway = {
      service    = "apigateway"
      source_arn = "${module.api_gateway.apigatewayv2_api_execution_arn}/*/*/*"
    }
  }
}

module "lambda_security_group" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "~> 4.0"

  name        = "lambda-sg-${local.lamdba_reports_name}"
  description = "Lambda security group for example usage"
  vpc_id      = module.vpc.vpc_id

  computed_ingress_with_source_security_group_id = [
    {
      rule                     = "http-80-tcp"
      source_security_group_id = module.api_gateway_security_group.security_group_id
    }
  ]
  number_of_computed_ingress_with_source_security_group_id = 1

  egress_rules = ["all-all"]
}


module "api_gateway" {
  source = "terraform-aws-modules/apigateway-v2/aws"

  name          = "${local.name}-api-gateway-http-vpc-links"
  description   = "HTTP API Gateway with VPC links"
  protocol_type = "HTTP"

  cors_configuration = {
    allow_headers = ["content-type", "x-amz-date", "authorization", "x-api-key", "x-amz-security-token", "x-amz-user-agent"]
    allow_methods = ["*"]
    allow_origins = ["*"]
  }

  create_api_domain_name = false

  integrations = {
    # "ANY /" = {
    #   lambda_arn             = module.lambda_function.lambda_function_arn
    #   payload_format_version = "2.0"
    #   timeout_milliseconds   = 12000
    # }

    "GET /dict" = {
      lambda_arn             = module.lambda_function_employees_reports.lambda_function_arn
      payload_format_version = "2.0"
      authorization_type     = "NONE"
      //integration_type   = "LAMBDA_PROXY"
    }

    "GET /string" = {
      lambda_arn             = module.lambda_function_employees_reports.lambda_function_arn
      payload_format_version = "2.0"
      authorization_type     = "NONE"
      //integration_type   = "LAMBDA_PROXY"
    }

    "POST /string" = {
      lambda_arn             = module.lambda_function_employees_reports.lambda_function_arn
      payload_format_version = "2.0"
      authorization_type     = "NONE"
      //integration_type   = "LAMBDA_PROXY"
    }

    "POST /close" = {
      lambda_arn             = module.lambda_function_employees_reports.lambda_function_arn
      payload_format_version = "2.0"
      authorization_type     = "NONE"
      //integration_type   = "LAMBDA_PROXY"
    }

    # "GET /alb-internal-route" = {
    #   connection_type    = "VPC_LINK"
    #   vpc_link           = "my-vpc"
    #   integration_uri    = module.alb.http_tcp_listener_arns[0]
    #   integration_type   = "HTTP_PROXY"
    #   integration_method = "ANY"
    # }

    "$default" = {
      lambda_arn = module.lambda_function_employees_reports.lambda_function_arn
    }
  }

  vpc_links = {
    my-vpc = {
      name               = "dev-vpc"
      security_group_ids = [module.api_gateway_security_group.security_group_id]
      subnet_ids         = module.vpc.public_subnets
    }
  }

  tags = local.tags
}

module "api_gateway_security_group" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "~> 4.0"

  name        = "${local.name}-api-gateway-sg"
  description = "API Gateway group"
  vpc_id      = module.vpc.vpc_id

  ingress_cidr_blocks = ["0.0.0.0/0"]
  ingress_rules       = ["http-80-tcp"]

  egress_rules = ["all-all"]

  tags = local.tags
}


#secrets

variable "db_secrets" {
  default = {
    username = module.db.db_instance_username
    password = module.db.db_instance_password
    engine = module.db.db_instance_engine
    host = module.db.db_instance_address
    port = module.db.db_instance_port
    dbname = module.db.db_instance_name
    dbInstanceIdentifier = module.db.db_instance_id
    dbarn = module.db.db_instance_arn
  }

  type = map(string)
}

resource "aws_secretsmanager_secret" "secretsRDS" {
   name = "${local.name}-rds-instance"
}

resource "aws_secretsmanager_secret_version" "secretsRDS" {
  secret_id     = aws_secretsmanager_secret.secretsRDS.id
  secret_string = jsonencode(var.db_secrets)
}

