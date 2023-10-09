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

  lamdba_dict_name = "dev-dict-operations"
  dict_operate_zip = "./build/dict_operate_data.zip"

  extract_bnovo_zip = "./build/extract_bnovo_data.zip"
  extract_bnovo_finance_zip = "./build/extract_bnovo_finance.zip"
  extract_bnovo_booking_zip = "./build/extract_bnovo_booking.zip"

  extract_tinkoff_account_zip = "./build/extract_tinkoff_account.zip"

  extract_email_reports_data_zip = "./build/extract_email_reports_data.zip"

  upload_psb_acquiring_zip = "./build/upload_psb_acquiring.zip"

  upload_ucb_account_zip = "./build/upload_ucb_account.zip"

  to_plan_extract_bnovo_fin = "./build/to_plan_extract_bnovo_fin.zip"

  to_plan_extract_psb = "./build/to_plan_extract_psb.zip"

  to_plan_extract_tinkoff = "./build/to_plan_extract_tinkoff.zip"


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

  #private_subnet_names = ["DEV Private Subnet One", "DEV Private Subnet Two"] error unsupported arg
  #database_subnet_names = ["DEV Database Subnet One", "DEV Database Subnet Two"]

  enable_dns_hostnames = true
  
  enable_dns_support   = true

  enable_nat_gateway = true
  single_nat_gateway = true
  
  create_database_subnet_group = true
  create_database_subnet_route_table     = true
  create_database_internet_gateway_route = true

  enable_secretsmanager_endpoint   = true
  secretsmanager_endpoint_private_dns_enabled = true
  secretsmanager_endpoint_security_group_ids  = [module.secrets_endpoints_security_group.security_group_id]
  #secretsmanager_endpoint_subnet_ids = private_subnets

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
  version = "5.9.0"

  identifier = local.name

  # All available versions: https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/CHAP_PostgreSQL.html#PostgreSQL.Concepts
  engine               = "postgres"
  engine_version       = "14.7"
  family               = "postgres14" # DB parameter group
  major_engine_version = "14.7"       # DB option group
  instance_class       = "db.t3.micro"

  auto_minor_version_upgrade = false

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
  
  attach_policy_statements = true
  policy_statements = {
    secretsmanager = {
      effect    = "Allow",
      actions   = ["secretsmanager:GetSecretValue"],
      resources = [aws_secretsmanager_secret.secretsRDS.arn]
    }
  } 



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


module "lambda_function_dict_operate" {
  source  = "terraform-aws-modules/lambda/aws"
  version = "~> 2.0"

  function_name =  "${local.lamdba_dict_name}-lambda"
  description   = "lambda function for support to operations with dictionary"
  handler       = "dict_operate_data.lambda_handler"
  runtime       = "python3.8"

  publish = true

  create_package         = false
  local_existing_package = local.dict_operate_zip

  attach_network_policy  = true
  
  attach_policy_statements = true
  policy_statements = {
    secretsmanager = {
      effect    = "Allow",
      actions   = ["secretsmanager:GetSecretValue"],
      resources = [aws_secretsmanager_secret.secretsRDS.arn]
    }
  } 


  vpc_subnet_ids         = module.vpc.private_subnets
  vpc_security_group_ids = [module.lambda_security_group.security_group_id]

  allowed_triggers = {
    AllowExecutionFromAPIGateway = {
      service    = "apigateway"
      source_arn = "${module.api_gateway.apigatewayv2_api_execution_arn}/*/*/*"
    }
  }
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

    "GET /close" = {
      lambda_arn             = module.lambda_function_employees_reports.lambda_function_arn
      payload_format_version = "2.0"
      authorization_type     = "NONE"
      //integration_type   = "LAMBDA_PROXY"
    }

    "GET /dict_operate" = {
      lambda_arn             = module.lambda_function_dict_operate.lambda_function_arn
      payload_format_version = "2.0"
      authorization_type     = "NONE"
      //integration_type   = "LAMBDA_PROXY"
    }

    "POST /dict_operate" = {
      lambda_arn             = module.lambda_function_dict_operate.lambda_function_arn
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


module "secrets_endpoints_security_group" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "~> 4.0"

  name        = "${local.name}-endpoint-sg-to-secretsmanager"
  description = "SG endpoints to secrets db"
  vpc_id      = module.vpc.vpc_id

  computed_ingress_with_source_security_group_id = [
    {
      rule                     = "all-tcp"
      description              = "Allow access from API call"
      source_security_group_id = module.lambda_security_group.security_group_id
    },
    #{
    #  rule                     = "all-all"
    #  description              = "Allow access from CRON lambda"
    #  source_security_group_id = module.lambda_cron_security_group.security_group_id
    #},
    {
      from_port                = 0
      to_port                  = 65535
      protocol                 = "tcp"
      description              = "Allow access from CRON lambda"
      source_security_group_id = module.lambda_cron_security_group.security_group_id
    },
  ]
  number_of_computed_ingress_with_source_security_group_id = 2

  egress_rules = ["all-all"]

  tags = local.tags
}

#secrets


resource "aws_secretsmanager_secret" "secretsRDS" {
   name = "${local.name}-rds-instance"
}

resource "aws_secretsmanager_secret_version" "secretsRDS" {
  secret_id     = aws_secretsmanager_secret.secretsRDS.id
  secret_string = <<EOF
   {
    "username": "${module.db.db_instance_username}",
    "password": "${module.db.db_instance_password}",
    "engine": "${module.db.db_instance_engine}",
    "host": "${module.db.db_instance_address}",
    "port": "${module.db.db_instance_port}",
    "dbname": "${module.db.db_instance_name}",
    "dbInstanceIdentifier": "${module.db.db_instance_id}",
    "dbarn": "${module.db.db_instance_arn}"
   }
  EOF
  #secret_string = jsonencode(var.db_secrets)
}

resource "aws_secretsmanager_secret" "reports_email" {
   name = "${local.name}-reports-email-cred"
}

resource "aws_secretsmanager_secret_version" "reports_email" {
  secret_id     = aws_secretsmanager_secret.reports_email.id
  secret_string = <<EOF
   {
    "email_address": "${var.reports_email}",
    "password": "${var.reports_email_password}",
    "s3_bucket_for_attachments": "${module.s3_bucket_for_data_processing.s3_bucket_id}"
   }
  EOF
  #secret_string = jsonencode(var.db_secrets)
}



module "lambda_function_bnovo_extract" {
  source = "terraform-aws-modules/lambda/aws"
  version = "~> 2.0"

  function_name = "${local.name}-bnovo-extract-lambda"
  description   = "lambda function for extract data from open API Bnovo"
  handler       = "extract_bnovo_data.lambda_handler"
  runtime       = "python3.8"

  publish = true

  timeout = 120

  create_package         = false
  local_existing_package = local.extract_bnovo_zip

  attach_network_policy  = true

  attach_policy_statements = true
  policy_statements = {
    secretsmanager = {
      effect    = "Allow",
      actions   = ["secretsmanager:GetSecretValue"],
      resources = [aws_secretsmanager_secret.secretsRDS.arn]
    }
  } 

  vpc_subnet_ids         = module.vpc.private_subnets
  vpc_security_group_ids = [module.lambda_cron_security_group.security_group_id]


  allowed_triggers = {
    HourlyCronInvoke = {
      principal  = "events.amazonaws.com"
      source_arn = aws_cloudwatch_event_rule.every_hour.arn
    }
  }

  tags = local.tags
}


module "lambda_function_bnovo_finance_extract" {
  source = "terraform-aws-modules/lambda/aws"
  version = "~> 2.0"

  function_name = "${local.name}-bnovo-finance-extract-lambda"
  description   = "lambda function for extract FINANCE data from open API Bnovo"
  handler       = "extract_bnovo_finance.lambda_handler"
  runtime       = "python3.8"

  publish = true

  create_package         = false
  local_existing_package = local.extract_bnovo_finance_zip

  attach_network_policy  = true

  timeout = 30

  attach_policy_statements = true
  policy_statements = {
    secretsmanager = {
      effect    = "Allow",
      actions   = ["secretsmanager:GetSecretValue"],
      resources = [aws_secretsmanager_secret.secretsRDS.arn]
    }
  } 

  vpc_subnet_ids         = module.vpc.private_subnets
  vpc_security_group_ids = [module.lambda_cron_security_group.security_group_id]

  tags = local.tags
}

module "lambda_function_bnovo_booking_extract" {
  source = "terraform-aws-modules/lambda/aws"
  version = "~> 2.0"

  function_name = "${local.name}-bnovo-booking-extract-lambda"
  description   = "lambda function for extract BOOKING and INVOICES data from open API Bnovo"
  handler       = "extract_bnovo_booking.lambda_handler"
  runtime       = "python3.8"

  publish = true

  create_package         = false
  local_existing_package = local.extract_bnovo_booking_zip

  attach_network_policy  = true

  timeout = 30

  attach_policy_statements = true
  policy_statements = {
    secretsmanager = {
      effect    = "Allow",
      actions   = ["secretsmanager:GetSecretValue"],
      resources = [aws_secretsmanager_secret.secretsRDS.arn]
    }
  } 

  vpc_subnet_ids         = module.vpc.private_subnets
  vpc_security_group_ids = [module.lambda_cron_security_group.security_group_id]

  tags = local.tags
}


module "lambda_function_plan_to_extract_bnovo_fin" {
  source = "terraform-aws-modules/lambda/aws"
  version = "~> 2.0"

  function_name = "${local.name}-plan-to-extract-bnovo-fin"
  description   = "lambda function for planing to launch extract FINANCE data from open API Bnovo"
  handler       = "to_plan_extract_bnovo_fin.lambda_handler"
  runtime       = "python3.8"

  publish = true

  create_package         = false
  local_existing_package = local.to_plan_extract_bnovo_fin

  attach_network_policy  = true

  attach_policy_statements = true
  policy_statements = {
    secretsmanager = {
      effect    = "Allow",
      actions   = ["secretsmanager:GetSecretValue"],
      resources = [aws_secretsmanager_secret.secretsRDS.arn]
    }
  } 

  vpc_subnet_ids         = module.vpc.private_subnets
  vpc_security_group_ids = [module.lambda_cron_security_group.security_group_id]


  #allowed_triggers = {
  #  HourlyCronInvoke = {
  #    principal  = "events.amazonaws.com"
  #    source_arn = aws_cloudwatch_event_rule.every_hour.arn
  #  }
  #}

  tags = local.tags
}

module "lambda_function_plan_to_extract_psb" {
  source = "terraform-aws-modules/lambda/aws"
  version = "~> 2.0"

  function_name = "${local.name}-plan-to-extract-psb"
  description   = "lambda function for planing to launch extract PAYMENTS data from open API PSB"
  handler       = "to_plan_extract_psb.lambda_handler"
  runtime       = "python3.8"

  publish = true

  create_package         = false
  local_existing_package = local.to_plan_extract_psb

  attach_network_policy  = true

  attach_policy_statements = true
  policy_statements = {
    secretsmanager = {
      effect    = "Allow",
      actions   = ["secretsmanager:GetSecretValue"],
      resources = [aws_secretsmanager_secret.secretsRDS.arn]
    }
  } 

  vpc_subnet_ids         = module.vpc.private_subnets
  vpc_security_group_ids = [module.lambda_cron_security_group.security_group_id]

  tags = local.tags
}

module "lambda_function_plan_to_extract_tinkoff" {
  source = "terraform-aws-modules/lambda/aws"
  version = "~> 2.0"

  function_name = "${local.name}-plan-to-extract-tinkoff"
  description   = "lambda function for planing to launch extract PAYMENTS data from open API TIMKOFF"
  handler       = "to_plan_extract_tinkoff.lambda_handler"
  runtime       = "python3.8"

  publish = true

  create_package         = false
  local_existing_package = local.to_plan_extract_tinkoff

  attach_network_policy  = true

  attach_policy_statements = true
  policy_statements = {
    secretsmanager = {
      effect    = "Allow",
      actions   = ["secretsmanager:GetSecretValue"],
      resources = [aws_secretsmanager_secret.secretsRDS.arn]
    }
  } 

  vpc_subnet_ids         = module.vpc.private_subnets
  vpc_security_group_ids = [module.lambda_cron_security_group.security_group_id]

  tags = local.tags
}

module "lambda_function_tinkoff_extract" {
  source = "terraform-aws-modules/lambda/aws"
  version = "~> 2.0"

  function_name = "${local.name}-tinkoff-extract-lambda"
  description   = "lambda function for extract Payment data from open API TINKOFF"
  handler       = "extract_tinkoff_account.lambda_handler"
  runtime       = "python3.8"

  publish = true

  create_package         = false
  local_existing_package = local.extract_tinkoff_account_zip

  timeout = 10

  attach_network_policy  = true

  attach_policy_statements = true
  policy_statements = {
    secretsmanager = {
      effect    = "Allow",
      actions   = ["secretsmanager:GetSecretValue"],
      resources = [aws_secretsmanager_secret.secretsRDS.arn]
    }
  } 

  vpc_subnet_ids         = module.vpc.private_subnets
  vpc_security_group_ids = [module.lambda_cron_security_group.security_group_id]


  #allowed_triggers = {
  #  HourlyCronInvoke = {
  #    principal  = "events.amazonaws.com"
  #    source_arn = aws_cloudwatch_event_rule.every_hour.arn
  #  }
  #}

  tags = local.tags
}

module "lambda_cron_security_group" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "~> 4.0"

  name        = "${local.name}-lambda-sg-cron-execute"
  description = "Lambda security group for functions invoking by cloudwath schedule cron"
  vpc_id      = module.vpc.vpc_id

  
  egress_rules = ["all-all"]

  tags = local.tags
}


// Create the "cron" schedule
resource "aws_cloudwatch_event_rule" "every_hour" {
  name = "${local.name}-hourly"
  schedule_expression = "cron(0/10 * * * ? *)"
}

// Set the action to perform when the event is triggered
resource "aws_cloudwatch_event_target" "invoke_lambda" {
  rule = aws_cloudwatch_event_rule.every_hour.name
  arn = module.lambda_function_bnovo_extract.lambda_function_arn
}

//s3 for mail data store for processing
module "s3_bucket_for_data_processing" {
  source = "terraform-aws-modules/s3-bucket/aws"

  bucket = "${local.name}-arbat-hotels-mail-income-data"
  force_destroy = true
}


module "lambda_function_psb_extract_java" {
  source = "terraform-aws-modules/lambda/aws"
  version = "~> 2.0"

  function_name = "${local.name}-psb-extract-lambda"
  description   = "lambda function for extract Payment data from open API PSB"
  handler       = "MySoapClient::handleRequest"
  runtime       = "java8"

  publish = true

  create_package         = false
  
  s3_existing_package = {
    bucket = "arbat-hotel-additional-data"
    key    = "java_lambda_artifacts/arbatSpringSoapClient-1.0-SNAPSHOT.jar"
  }

  timeout = 180
  memory_size = 512

  attach_network_policy  = true

  attach_policy_statements = true
  policy_statements = {
    secretsmanager = {
      effect    = "Allow",
      actions   = ["secretsmanager:GetSecretValue"],
      resources = [aws_secretsmanager_secret.secretsRDS.arn]
    },
    s3_read = {
      effect    = "Allow",
      actions   = ["s3:GetObject"],
      resources = ["arn:aws:s3:::arbat-hotel-additional-data/psb-cert/*"]
    }
    s3_bucket_read = {
      effect    = "Allow",
      actions   = ["s3:ListBucket"],
      resources = ["arn:aws:s3:::arbat-hotel-additional-data"]
    }
  } 

  vpc_subnet_ids         = module.vpc.private_subnets
  vpc_security_group_ids = [module.lambda_cron_security_group.security_group_id]


  #allowed_triggers = {
  #  HourlyCronInvoke = {
  #    principal  = "events.amazonaws.com"
  #    source_arn = aws_cloudwatch_event_rule.every_hour.arn
  #  }
  #}

  tags = local.tags
}

module "lambda_function_extract_email_reports" {
  source = "terraform-aws-modules/lambda/aws"
  version = "~> 2.0"

  function_name = "${local.name}-extract-email-reports-lambda"
  description   = "lambda function for extract EMAIL reports and put them into S3"
  handler       = "extract_email_reports_data.lambda_handler"
  runtime       = "python3.8"

  publish = true

  create_package         = false
  local_existing_package = local.extract_email_reports_data_zip

  timeout = 60

  attach_network_policy  = true

  attach_policy_statements = true
  policy_statements = {
    secretsmanager = {
      effect    = "Allow",
      actions   = ["secretsmanager:GetSecretValue"],
      resources = [aws_secretsmanager_secret.reports_email.arn]
    },
    s3_read = {
      effect    = "Allow",
      actions   = ["s3:PutObject"],
      resources = ["${module.s3_bucket_for_data_processing.s3_bucket_arn}/*"]
    }
  } 

  vpc_subnet_ids         = module.vpc.private_subnets
  vpc_security_group_ids = [module.lambda_cron_security_group.security_group_id]


  #allowed_triggers = {
  #  HourlyCronInvoke = {
  #    principal  = "events.amazonaws.com"
  #    source_arn = aws_cloudwatch_event_rule.every_hour.arn
  #  }
  #}

  tags = local.tags
}

module "lambda_function_upload_psb_acquiring" {
  source = "terraform-aws-modules/lambda/aws"
  version = "~> 2.0"

  function_name = "${local.name}-upload-psb-acquiring-lambda"
  description   = "lambda function for upload acquiring PSB data from xls S3 to RDS"
  handler       = "upload_psb_acquiring.lambda_handler"
  runtime       = "python3.8"

  publish = true

  create_package         = false
  local_existing_package = local.upload_psb_acquiring_zip

  timeout = 60

  attach_network_policy  = true

  attach_policy_statements = true
  policy_statements = {
    secretsmanager_rds = {
      effect    = "Allow",
      actions   = ["secretsmanager:GetSecretValue"],
      resources = [aws_secretsmanager_secret.secretsRDS.arn]
    },
    secretsmanager_s3 = {
      effect    = "Allow",
      actions   = ["secretsmanager:GetSecretValue"],
      resources = [aws_secretsmanager_secret.reports_email.arn]
    },
    s3_read = {
      effect    = "Allow",
      actions   = ["s3:GetObject", "s3:PutObject", "s3:CopyObject", "s3:DeleteObject"],
      resources = ["${module.s3_bucket_for_data_processing.s3_bucket_arn}/*"]
    },
    s3_bucket_read = {
      effect    = "Allow",
      actions   = ["s3:ListBucket"],
      resources = ["${module.s3_bucket_for_data_processing.s3_bucket_arn}"]
    }
  } 

  vpc_subnet_ids         = module.vpc.private_subnets
  vpc_security_group_ids = [module.lambda_cron_security_group.security_group_id]


  #allowed_triggers = {
  #  HourlyCronInvoke = {
  #    principal  = "events.amazonaws.com"
  #    source_arn = aws_cloudwatch_event_rule.every_hour.arn
  #  }
  #}

  tags = local.tags
}

module "lambda_function_upload_ucb_account" {
  source = "terraform-aws-modules/lambda/aws"
  version = "~> 2.0"

  function_name = "${local.name}-upload-ucs-account-lambda"
  description   = "lambda function for upload UCP payment data from csv S3 to RDS"
  handler       = "upload_ucb_account.lambda_handler"
  runtime       = "python3.8"

  publish = true

  create_package         = false
  local_existing_package = local.upload_ucb_account_zip

  timeout = 60

  attach_network_policy  = true

  attach_policy_statements = true
  policy_statements = {
    secretsmanager_rds = {
      effect    = "Allow",
      actions   = ["secretsmanager:GetSecretValue"],
      resources = [aws_secretsmanager_secret.secretsRDS.arn]
    },
    secretsmanager_s3 = {
      effect    = "Allow",
      actions   = ["secretsmanager:GetSecretValue"],
      resources = [aws_secretsmanager_secret.reports_email.arn]
    },
    s3_read = {
      effect    = "Allow",
      actions   = ["s3:GetObject", "s3:PutObject", "s3:CopyObject", "s3:DeleteObject"],
      resources = ["${module.s3_bucket_for_data_processing.s3_bucket_arn}/*"]
    },
    s3_bucket_read = {
      effect    = "Allow",
      actions   = ["s3:ListBucket"],
      resources = ["${module.s3_bucket_for_data_processing.s3_bucket_arn}"]
    }
  } 

  vpc_subnet_ids         = module.vpc.private_subnets
  vpc_security_group_ids = [module.lambda_cron_security_group.security_group_id]


  #allowed_triggers = {
  #  HourlyCronInvoke = {
  #    principal  = "events.amazonaws.com"
  #    source_arn = aws_cloudwatch_event_rule.every_hour.arn
  #  }
  #}

  tags = local.tags
}