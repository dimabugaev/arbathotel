resource "aws_secretsmanager_secret" "reports_email" {
  name = "${local.prefixname}-reports-email-cred"
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

//s3 for mail data store for processing
module "s3_bucket_for_data_processing" {
  source = "terraform-aws-modules/s3-bucket/aws"

  bucket        = "${local.prefixname}-arbat-hotels-mail-income-data"
  force_destroy = true
}

module "banks_extract_security_group" {
  source = "terraform-aws-modules/security-group/aws"
  #version = "~> 4.0"

  name        = "${local.prefixname}-lambda-sg-banks-extract"
  description = "Lambda security group for functions extract from BANKS"
  vpc_id      = data.terraform_remote_state.common.outputs.vpc_id


  egress_rules = ["all-all"]

  tags = local.tags
}

module "lambda_function_plan_to_extract_psb" {
  source = "terraform-aws-modules/lambda/aws"
  #version = "~> 2.0"

  function_name                     = "${local.prefixname}-plan-to-extract-psb"
  description                       = "lambda function for planing to launch extract PAYMENTS data from open API PSB"
  handler                           = "to_plan_extract_psb.lambda_handler"
  runtime                           = "python3.8"
  cloudwatch_logs_retention_in_days = 1

  publish = true

  create_package         = false
  local_existing_package = "${var.buildpath}${var.to_plan_extract_psb_zip}"

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
  vpc_security_group_ids = [data.terraform_remote_state.common.outputs.sg_access_to_secretsmanager, module.banks_extract_security_group.security_group_id]

  tags = local.tags
}

module "lambda_function_plan_to_extract_tinkoff" {
  source = "terraform-aws-modules/lambda/aws"
  #version = "~> 2.0"

  function_name                     = "${local.prefixname}-plan-to-extract-tinkoff"
  description                       = "lambda function for planing to launch extract PAYMENTS data from open API TIMKOFF"
  handler                           = "to_plan_extract_tinkoff.lambda_handler"
  runtime                           = "python3.8"
  cloudwatch_logs_retention_in_days = 1

  publish = true

  create_package         = false
  local_existing_package = "${var.buildpath}${var.to_plan_extract_tinkoff}"

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
  vpc_security_group_ids = [data.terraform_remote_state.common.outputs.sg_access_to_secretsmanager, module.banks_extract_security_group.security_group_id]

  tags = local.tags
}

module "lambda_function_plan_to_extract_alfa" {
  source = "terraform-aws-modules/lambda/aws"
  #version = "~> 2.0"

  function_name                     = "${local.prefixname}-plan-to-extract-alfa"
  description                       = "lambda function for planing to launch extract PAYMENTS data from open API ALFA"
  handler                           = "to_plan_extract_alfa.lambda_handler"
  runtime                           = "python3.8"
  cloudwatch_logs_retention_in_days = 1

  publish = true

  create_package         = false
  local_existing_package = "${var.buildpath}${var.to_plan_extract_alfa}"

  timeout = 60

  attach_network_policy = true

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
      resources = ["arn:aws:s3:::arbat-hotel-additional-data/alfa-cert/*"]
    },
    s3_bucket_read = {
      effect    = "Allow",
      actions   = ["s3:ListBucket"],
      resources = ["arn:aws:s3:::arbat-hotel-additional-data"]
    }
  }

  environment_variables = {
    RDS_SECRET = aws_secretsmanager_secret.secretsRDS.name
  }

  vpc_subnet_ids         = data.terraform_remote_state.common.outputs.private_subnets
  vpc_security_group_ids = [data.terraform_remote_state.common.outputs.sg_access_to_secretsmanager, module.banks_extract_security_group.security_group_id]

  tags = local.tags
}

module "lambda_function_tinkoff_extract" {
  source = "terraform-aws-modules/lambda/aws"
  #version = "~> 2.0"

  function_name                     = "${local.prefixname}-tinkoff-extract-lambda"
  description                       = "lambda function for extract Payment data from open API TINKOFF"
  handler                           = "extract_tinkoff_account.lambda_handler"
  runtime                           = "python3.8"
  cloudwatch_logs_retention_in_days = 1

  publish = true

  create_package         = false
  local_existing_package = "${var.buildpath}${var.extract_tinkoff_account_zip}"

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
  vpc_security_group_ids = [data.terraform_remote_state.common.outputs.sg_access_to_secretsmanager, module.banks_extract_security_group.security_group_id]

  tags = local.tags
}

module "lambda_function_alfa_extract" {
  source = "terraform-aws-modules/lambda/aws"
  #version = "~> 2.0"

  function_name                     = "${local.prefixname}-alfa-extract-lambda"
  description                       = "lambda function for extract Payment data from open API ALFA"
  handler                           = "extract_alfa_account.lambda_handler"
  runtime                           = "python3.8"
  cloudwatch_logs_retention_in_days = 1

  publish = true

  create_package         = false
  local_existing_package = "${var.buildpath}${var.extract_alfa_account_zip}"

  timeout = 60

  attach_network_policy = true

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
      resources = ["arn:aws:s3:::arbat-hotel-additional-data/alfa-cert/*"]
    },
    s3_bucket_read = {
      effect    = "Allow",
      actions   = ["s3:ListBucket"],
      resources = ["arn:aws:s3:::arbat-hotel-additional-data"]
    }
  }

  environment_variables = {
    RDS_SECRET = aws_secretsmanager_secret.secretsRDS.name
  }

  vpc_subnet_ids         = data.terraform_remote_state.common.outputs.private_subnets
  vpc_security_group_ids = [data.terraform_remote_state.common.outputs.sg_access_to_secretsmanager, module.banks_extract_security_group.security_group_id]

  tags = local.tags
}

module "lambda_function_psb_extract_java_tire_1" {
  source = "terraform-aws-modules/lambda/aws"
  #version = "~> 2.0"

  function_name                     = "${local.prefixname}-psb-extract-lambda-tire-1"
  description                       = "lambda function for extract Payment data from open API PSB"
  handler                           = "MySoapClient::handleRequest"
  runtime                           = "java8"
  cloudwatch_logs_retention_in_days = 1

  publish = true

  create_package = false

  s3_existing_package = {
    bucket = "arbat-hotel-additional-data"
    key    = "java_lambda_artifacts/arbatSpringSoapClient-1.0-SNAPSHOT.jar"
  }

  timeout     = 180
  memory_size = 512

  attach_network_policy = true

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
    },
    s3_bucket_read = {
      effect    = "Allow",
      actions   = ["s3:ListBucket"],
      resources = ["arn:aws:s3:::arbat-hotel-additional-data"]
    }
  }

  environment_variables = {
    RDS_SECRET = aws_secretsmanager_secret.secretsRDS.name
  }

  vpc_subnet_ids         = data.terraform_remote_state.common.outputs.private_subnets
  vpc_security_group_ids = [data.terraform_remote_state.common.outputs.sg_access_to_secretsmanager, module.banks_extract_security_group.security_group_id]

  tags = local.tags
}

module "lambda_function_psb_extract_java_tire_2" {
  source = "terraform-aws-modules/lambda/aws"
  #version = "~> 2.0"

  function_name                     = "${local.prefixname}-psb-extract-lambda-tire-2"
  description                       = "lambda function for extract Payment data from open API PSB"
  handler                           = "MySoapClient::handleRequest"
  runtime                           = "java8"
  cloudwatch_logs_retention_in_days = 1

  publish = true

  create_package = false

  s3_existing_package = {
    bucket = "arbat-hotel-additional-data"
    key    = "java_lambda_artifacts/arbatSpringSoapClient-1.0-SNAPSHOT.jar"
  }

  timeout     = 180
  memory_size = 512

  attach_network_policy = true

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
    },
    s3_bucket_read = {
      effect    = "Allow",
      actions   = ["s3:ListBucket"],
      resources = ["arn:aws:s3:::arbat-hotel-additional-data"]
    }
  }

  environment_variables = {
    RDS_SECRET = aws_secretsmanager_secret.secretsRDS.name
  }

  vpc_subnet_ids         = data.terraform_remote_state.common.outputs.private_subnets
  vpc_security_group_ids = [data.terraform_remote_state.common.outputs.sg_access_to_secretsmanager, module.banks_extract_security_group.security_group_id]

  tags = local.tags
}

module "lambda_function_psb_extract_java_tire_3" {
  source = "terraform-aws-modules/lambda/aws"
  #version = "~> 2.0"

  function_name                     = "${local.prefixname}-psb-extract-lambda-tire-3"
  description                       = "lambda function for extract Payment data from open API PSB"
  handler                           = "MySoapClient::handleRequest"
  runtime                           = "java8"
  cloudwatch_logs_retention_in_days = 1

  publish = true

  create_package = false

  s3_existing_package = {
    bucket = "arbat-hotel-additional-data"
    key    = "java_lambda_artifacts/arbatSpringSoapClient-1.0-SNAPSHOT.jar"
  }

  timeout     = 180
  memory_size = 512

  attach_network_policy = true

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
    },
    s3_bucket_read = {
      effect    = "Allow",
      actions   = ["s3:ListBucket"],
      resources = ["arn:aws:s3:::arbat-hotel-additional-data"]
    }
  }

  environment_variables = {
    RDS_SECRET = aws_secretsmanager_secret.secretsRDS.name
  }

  vpc_subnet_ids         = data.terraform_remote_state.common.outputs.private_subnets
  vpc_security_group_ids = [data.terraform_remote_state.common.outputs.sg_access_to_secretsmanager, module.banks_extract_security_group.security_group_id]

  tags = local.tags
}



module "lambda_function_extract_email_reports" {
  source = "terraform-aws-modules/lambda/aws"
  #version = "~> 2.0"

  function_name                     = "${local.prefixname}-extract-email-reports-lambda"
  description                       = "lambda function for extract EMAIL reports and put them into S3"
  handler                           = "extract_email_reports_data.lambda_handler"
  runtime                           = "python3.8"
  cloudwatch_logs_retention_in_days = 1

  publish = true

  create_package         = false
  local_existing_package = "${var.buildpath}${var.extract_email_reports_data_zip}"

  timeout = 60

  attach_network_policy = true

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

  environment_variables = {
    RDS_SECRET    = aws_secretsmanager_secret.secretsRDS.name
    REPORT_SECRET = aws_secretsmanager_secret.reports_email.name
  }

  vpc_subnet_ids         = data.terraform_remote_state.common.outputs.private_subnets
  vpc_security_group_ids = [data.terraform_remote_state.common.outputs.sg_access_to_secretsmanager, module.banks_extract_security_group.security_group_id]

  tags = local.tags
}


module "lambda_function_upload_psb_acquiring" {
  source = "terraform-aws-modules/lambda/aws"
  #version = "~> 2.0"

  function_name                     = "${local.prefixname}-upload-psb-acquiring-lambda"
  description                       = "lambda function for upload acquiring PSB data from xls S3 to RDS"
  handler                           = "upload_psb_acquiring.lambda_handler"
  runtime                           = "python3.8"
  cloudwatch_logs_retention_in_days = 1

  publish = true

  create_package         = false
  local_existing_package = "${var.buildpath}${var.upload_psb_acquiring_zip}"

  timeout = 60

  attach_network_policy = true

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

  environment_variables = {
    RDS_SECRET    = aws_secretsmanager_secret.secretsRDS.name
    REPORT_SECRET = aws_secretsmanager_secret.reports_email.name
  }

  vpc_subnet_ids         = data.terraform_remote_state.common.outputs.private_subnets
  vpc_security_group_ids = [data.terraform_remote_state.common.outputs.sg_access_to_secretsmanager, module.banks_extract_security_group.security_group_id]

  tags = local.tags
}

module "lambda_function_upload_ucb_account" {
  source = "terraform-aws-modules/lambda/aws"
  #version = "~> 2.0"

  function_name                     = "${local.prefixname}-upload-ucs-account-lambda"
  description                       = "lambda function for upload UCP payment data from csv S3 to RDS"
  handler                           = "upload_ucb_account.lambda_handler"
  runtime                           = "python3.8"
  cloudwatch_logs_retention_in_days = 1

  publish = true

  create_package         = false
  local_existing_package = "${var.buildpath}${var.upload_ucb_account_zip}"

  timeout = 60

  attach_network_policy = true

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

  environment_variables = {
    RDS_SECRET    = aws_secretsmanager_secret.secretsRDS.name
    REPORT_SECRET = aws_secretsmanager_secret.reports_email.name
  }

  vpc_subnet_ids         = data.terraform_remote_state.common.outputs.private_subnets
  vpc_security_group_ids = [data.terraform_remote_state.common.outputs.sg_access_to_secretsmanager, module.banks_extract_security_group.security_group_id]

  tags = local.tags
}

