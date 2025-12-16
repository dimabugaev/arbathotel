#EXTRACT functions

module "bnovo_extract_security_group" {
  source = "terraform-aws-modules/security-group/aws"
  #version = "~> 4.0"

  name        = "${local.prefixname}-lambda-sg-bnovo-extract"
  description = "Lambda security group for functions extract from bnovo"
  vpc_id      = data.terraform_remote_state.common.outputs.vpc_id


  egress_rules = ["all-all"]

  tags = local.tags
}

module "lambda_function_bnovo_master_data_extract" {
  source = "terraform-aws-modules/lambda/aws"
  #version = "~> 2.0"

  function_name                     = "${local.prefixname}-bnovo-extract-lambda"
  description                       = "lambda function for extract data from open API Bnovo"
  handler                           = "extract_bnovo_data.lambda_handler"
  runtime                           = "python3.10"
  cloudwatch_logs_retention_in_days = 1

  publish = true

  timeout = 120

  create_package         = false
  local_existing_package = "${var.buildpath}${var.extract_bnovo_data_zip}"

  attach_network_policy = true

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
  vpc_security_group_ids = [data.terraform_remote_state.common.outputs.sg_access_to_secretsmanager, module.bnovo_extract_security_group.security_group_id]

  layers = [data.terraform_remote_state.common.outputs.lambda_layer_common_arn]

  tags = local.tags
}

module "lambda_function_bnovo_invoices_extract" {
  source = "terraform-aws-modules/lambda/aws"
  #version = "~> 2.0"

  function_name                     = "${local.prefixname}-bnovo-invoices-extract-lambda"
  description                       = "lambda function for extract invoices from open API Bnovo"
  handler                           = "extract_bnovo_invoices.lambda_handler"
  runtime                           = "python3.10"
  cloudwatch_logs_retention_in_days = 1

  publish = true

  timeout = 900

  create_package         = false
  local_existing_package = "${var.buildpath}${var.extract_bnovo_invoices_zip}"

  attach_network_policy = true

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
  vpc_security_group_ids = [data.terraform_remote_state.common.outputs.sg_access_to_secretsmanager, module.bnovo_extract_security_group.security_group_id]

  layers = [data.terraform_remote_state.common.outputs.lambda_layer_common_arn]

  tags = local.tags
}

module "lambda_function_bnovo_finance_extract" {
  source = "terraform-aws-modules/lambda/aws"
  #version = "~> 2.0"

  function_name                     = "${local.prefixname}-bnovo-finance-extract-lambda"
  description                       = "lambda function for extract FINANCE data from open API Bnovo"
  handler                           = "extract_bnovo_finance.lambda_handler"
  runtime                           = "python3.10"
  cloudwatch_logs_retention_in_days = 1

  publish = true

  create_package         = false
  local_existing_package = "${var.buildpath}${var.extract_bnovo_finance_zip}"

  attach_network_policy = true

  timeout     = 900
  memory_size = 512

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
  vpc_security_group_ids = [data.terraform_remote_state.common.outputs.sg_access_to_secretsmanager, module.bnovo_extract_security_group.security_group_id]

  layers = [data.terraform_remote_state.common.outputs.lambda_layer_common_arn]

  tags = local.tags
}

module "lambda_function_bnovo_booking_extract" {
  source = "terraform-aws-modules/lambda/aws"
  #version = "~> 2.0"

  function_name                     = "${local.prefixname}-bnovo-booking-extract-lambda"
  description                       = "lambda function for extract BOOKING and INVOICES data from open API Bnovo"
  handler                           = "extract_bnovo_booking.lambda_handler"
  runtime                           = "python3.10"
  cloudwatch_logs_retention_in_days = 1

  publish = true

  create_package         = false
  local_existing_package = "${var.buildpath}${var.extract_bnovo_booking_zip}"

  attach_network_policy = true

  timeout     = 900
  memory_size = 512

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
  vpc_security_group_ids = [data.terraform_remote_state.common.outputs.sg_access_to_secretsmanager, module.bnovo_extract_security_group.security_group_id]

  layers = [data.terraform_remote_state.common.outputs.lambda_layer_common_arn]

  tags = local.tags
}

module "lambda_function_plan_to_extract_bnovo_fin" {
  source = "terraform-aws-modules/lambda/aws"
  #version = "~> 2.0"

  function_name                     = "${local.prefixname}-plan-to-extract-bnovo-fin"
  description                       = "lambda function for planing to launch extract FINANCE data from open API Bnovo"
  handler                           = "to_plan_extract_bnovo_fin.lambda_handler"
  runtime                           = "python3.10"
  cloudwatch_logs_retention_in_days = 1

  publish = true

  create_package         = false
  local_existing_package = "${var.buildpath}${var.to_plan_extract_bnovo_fin_zip}"

  timeout = 120

  attach_network_policy = true

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
  vpc_security_group_ids = [data.terraform_remote_state.common.outputs.sg_access_to_secretsmanager, module.bnovo_extract_security_group.security_group_id]

  layers = [data.terraform_remote_state.common.outputs.lambda_layer_common_arn]

  tags = local.tags
}

module "lambda_function_plan_to_extract_bnovo_booking" {
  source = "terraform-aws-modules/lambda/aws"
  #version = "~> 2.0"

  function_name                     = "${local.prefixname}-plan-to-extract-bnovo-booking"
  description                       = "lambda function for planing to launch extract BOOKING data from open API Bnovo"
  handler                           = "to_plan_extract_bnovo_booking.lambda_handler"
  runtime                           = "python3.10"
  cloudwatch_logs_retention_in_days = 1

  publish = true

  create_package         = false
  local_existing_package = "${var.buildpath}${var.to_plan_extract_bnovo_booking_zip}"

  timeout = 60

  attach_network_policy = true

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
  vpc_security_group_ids = [data.terraform_remote_state.common.outputs.sg_access_to_secretsmanager, module.bnovo_extract_security_group.security_group_id]

  layers = [data.terraform_remote_state.common.outputs.lambda_layer_common_arn]

  tags = local.tags
}

module "lambda_function_extract_bnovo_guests" {
  source = "terraform-aws-modules/lambda/aws"
  #version = "~> 2.0"

  function_name                     = "${local.prefixname}-extract-bnovo-guests"
  description                       = "lambda function to launch extract GUESTS data from open API Bnovo"
  handler                           = "extract_bnovo_guests.lambda_handler"
  runtime                           = "python3.10"
  cloudwatch_logs_retention_in_days = 1

  publish = true

  create_package         = false
  local_existing_package = "${var.buildpath}${var.extract_bnovo_guests_zip}"

  timeout = 120

  attach_network_policy = true

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
  vpc_security_group_ids = [data.terraform_remote_state.common.outputs.sg_access_to_secretsmanager, module.bnovo_extract_security_group.security_group_id]

  layers = [data.terraform_remote_state.common.outputs.lambda_layer_common_arn]

  tags = local.tags
}

module "lambda_function_extract_bnovo_ufms" {
  source = "terraform-aws-modules/lambda/aws"
  #version = "~> 2.0"

  function_name                     = "${local.prefixname}-extract-bnovo-ufms"
  description                       = "lambda function extract sent data to UFMS from open API Bnovo"
  handler                           = "extract_bnovo_ufms.lambda_handler"
  runtime                           = "python3.10"
  cloudwatch_logs_retention_in_days = 1

  publish = true

  create_package         = false
  local_existing_package = "${var.buildpath}${var.extract_bnovo_ufms_zip}"

  timeout = 120

  attach_network_policy = true

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
  vpc_security_group_ids = [data.terraform_remote_state.common.outputs.sg_access_to_secretsmanager, module.bnovo_extract_security_group.security_group_id]


  tags = local.tags
}

module "lambda_function_plan_to_extract_frequently_bnovo" {
  source = "terraform-aws-modules/lambda/aws"
  #version = "~> 2.0"

  function_name                     = "${local.prefixname}-plan-to-extract-frequently-bnovo"
  description                       = "lambda function for planing frequently extract data from Bnovo"
  handler                           = "to_plan_extract_frequently_bnovo.lambda_handler"
  runtime                           = "python3.10"
  cloudwatch_logs_retention_in_days = 1

  publish = true

  create_package         = false
  local_existing_package = "${var.buildpath}${var.to_plan_extract_frequently_bnovo_zip}"

  timeout = 10

  attach_network_policy = true

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
  vpc_security_group_ids = [data.terraform_remote_state.common.outputs.sg_access_to_secretsmanager, module.bnovo_extract_security_group.security_group_id]

  layers = [data.terraform_remote_state.common.outputs.lambda_layer_common_arn]

  tags = local.tags
}



