#API Lambdas
module "api_gateway_security_group" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "~> 4.0"

  name        = "${local.prefixname}-api-gateway-sg"
  description = "API Gateway group"
  vpc_id      = data.terraform_remote_state.common.outputs.vpc_id

  ingress_cidr_blocks = ["0.0.0.0/0"]
  ingress_rules       = ["http-80-tcp"]

  egress_rules = ["all-all"]

  tags = local.tags
}

module "api_gateway" {
  source = "terraform-aws-modules/apigateway-v2/aws"

  name          = "${local.prefixname}-api-gateway-http-vpc-links"
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

    #"$default" = {
    #  lambda_arn = module.lambda_function_employees_reports.lambda_function_arn
    #}
  }

  vpc_links = {
    my-vpc = {
      name               = "${local.prefixname}-vpc"
      security_group_ids = [module.api_gateway_security_group.security_group_id]
      subnet_ids         = data.terraform_remote_state.common.outputs.public_subnets
    }
  }

  tags = local.tags
}

module "lambda_api_security_group" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "~> 4.0"

  name        = "${local.prefixname}-lambda-sg-acces-from-api"
  description = "Lambda security group for get access fro API gateway"
  vpc_id      = data.terraform_remote_state.common.outputs.vpc_id

  computed_ingress_with_source_security_group_id = [
    {
      rule                     = "http-80-tcp"
      source_security_group_id = module.api_gateway_security_group.security_group_id
    }
  ]
  number_of_computed_ingress_with_source_security_group_id = 1

  egress_rules = ["all-all"]
}

module "lambda_function_employees_reports" {
  source  = "terraform-aws-modules/lambda/aws"
  version = "~> 2.0"

  function_name =  "${local.prefixname}-reports-operations-lambda"
  description   = "lambda function for support to work operations reports"
  handler       = "employees_reports_data.lambda_handler"
  runtime       = "python3.8"

  publish = true

  create_package         = false
  local_existing_package = "${var.buildpath}${var.employees_reports_zip}"

  attach_network_policy  = true
  
  attach_policy_statements = true
  policy_statements = {
    secretsmanager = {
      effect    = "Allow",
      actions   = ["secretsmanager:GetSecretValue"],
      resources = [aws_secretsmanager_secret.secretsRDS.arn]
    }
  } 


  environment_variables = {
    RDS_SECRET = aws_secretsmanager_secret.secretsRDS.name
  }

  vpc_subnet_ids         = data.terraform_remote_state.common.outputs.private_subnets
  vpc_security_group_ids = [data.terraform_remote_state.common.outputs.sg_access_to_secretsmanager, module.lambda_api_security_group.security_group_id]

  allowed_triggers = {
    AllowExecutionFromAPIGateway = {
      service    = "apigateway"
      source_arn = "${module.api_gateway.apigatewayv2_api_execution_arn}/*/*/*"
    }
  }
}

module "lambda_function_dict_operate" {
  source  = "terraform-aws-modules/lambda/aws"
  version = "~> 2.0"

  function_name =  "${local.prefixname}-dict-operations-lambda"
  description   = "lambda function for support to operations with dictionary"
  handler       = "dict_operate_data.lambda_handler"
  runtime       = "python3.8"

  publish = true

  create_package         = false
  local_existing_package = "${var.buildpath}${var.dict_operate_zip}"

  attach_network_policy  = true
  
  attach_policy_statements = true
  policy_statements = {
    secretsmanager = {
      effect    = "Allow",
      actions   = ["secretsmanager:GetSecretValue"],
      resources = [aws_secretsmanager_secret.secretsRDS.arn]
    }
  } 

  environment_variables = {
    RDS_SECRET = aws_secretsmanager_secret.secretsRDS.name
  }

  vpc_subnet_ids         = data.terraform_remote_state.common.outputs.private_subnets
  vpc_security_group_ids = [data.terraform_remote_state.common.outputs.sg_access_to_secretsmanager, module.lambda_api_security_group.security_group_id]

  allowed_triggers = {
    AllowExecutionFromAPIGateway = {
      service    = "apigateway"
      source_arn = "${module.api_gateway.apigatewayv2_api_execution_arn}/*/*/*"
    }
  }
}
