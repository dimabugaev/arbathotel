
resource "aws_iam_role" "iam_ecs_service_role" {
  name = "${local.prefixname}-ecs-task-execution-role"
  tags = local.tags

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
    "Statement": [
        {
        "Sid": "",
        "Effect": "Allow",
        "Principal": {
            "Service": ["ecs.amazonaws.com", "ecs-tasks.amazonaws.com"]
        },
        "Action": "sts:AssumeRole"
        }
    ]
    }
    EOF
}

resource "aws_iam_role_policy" "iam_ecs_service_police" {

  name   = "${local.prefixname}-ecs-task-execution-policy"
  role   = aws_iam_role.iam_ecs_service_role.id
  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "ecs:*",
        "ecr:*",
        "logs:*",
        "cloudwatch:*",
        "elasticloadbalancing:*"
      ],
      "Resource": "*"
    }
  ]
}
EOF
}

resource "aws_cloudwatch_log_group" "log_for_ecs_cluster" {
  name              = "/aws/ecs/${local.prefixname}-ecs-cluster"
  retention_in_days = 3
}

resource "aws_ecr_repository" "repo_dbt" {
  name                 = "${local.prefixname}-ecr-repo"
  image_tag_mutability = "MUTABLE"
  force_delete         = true

  image_scanning_configuration {
    scan_on_push = true
  }
  tags = local.tags
}

resource "aws_ecs_cluster" "ecs_cluster" {
  name = "${local.prefixname}-ecs-cluster"
  tags = local.tags
}

resource "aws_ecs_task_definition" "dbt_task" {
  family                   = "${local.prefixname}-dbt-task"
  execution_role_arn       = aws_iam_role.iam_ecs_service_role.arn
  task_role_arn            = aws_iam_role.iam_ecs_service_role.arn
  cpu                      = 512
  memory                   = 1024
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  tags                     = local.tags

  container_definitions = <<EOF
    [
    {
        "name": "dbt-container",
        "image": "${aws_ecr_repository.repo_dbt.repository_url}:dbt-arbat-transform-latest",
        "cpu": 512,
        "memory": 1024,    
        "logConfiguration": {
        "logDriver": "awslogs",
        "options": {
            "awslogs-region": "${var.aws_region}",
            "awslogs-group": "${aws_cloudwatch_log_group.log_for_ecs_cluster.name}",
            "awslogs-stream-prefix": "ecs"
        }
        }
    }
    ]
    EOF
}

resource "aws_ecs_task_definition" "soap_task" {
  family                   = "${local.prefixname}-soap-task"
  execution_role_arn       = aws_iam_role.iam_ecs_service_role.arn
  task_role_arn            = aws_iam_role.iam_ecs_service_role.arn
  cpu                      = 1024
  memory                   = 2048
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  tags                     = local.tags

  container_definitions = <<EOF
    [
    {
        "name": "soap-container",
        "image": "${aws_ecr_repository.repo_dbt.repository_url}:java-soap-client-latest",
        "cpu": 1024,
        "memory": 2048,
        "logConfiguration": {
        "logDriver": "awslogs",
        "options": {
            "awslogs-region": "${var.aws_region}",
            "awslogs-group": "${aws_cloudwatch_log_group.log_for_ecs_cluster.name}",
            "awslogs-stream-prefix": "ecs"
        }
        },
        "environment": [
          {
            "name": "source_id",
            "value": "$${source_id}"
          },
          {
            "name": "datefrom",
            "value": "$${datefrom}"
          },
          {
            "name": "dateto",
            "value": "$${dateto}"
          }
        ]
    }
    ]
    EOF
}

module "ecs_task_security_group" {
  source = "terraform-aws-modules/security-group/aws"
  #version = "~> 4.0"

  name        = "${local.prefixname}-ecs-task-sg-dbt-run"
  description = "Security group for launch DBT transformations"
  vpc_id      = data.terraform_remote_state.common.outputs.vpc_id


  egress_rules = ["all-all"]

  tags = local.tags
}

resource "aws_secretsmanager_secret" "secretsECS" {
  name = "${local.prefixname}-ecs-cluster-data"
}

resource "aws_secretsmanager_secret_version" "secretsECS" {
  secret_id     = aws_secretsmanager_secret.secretsECS.id
  secret_string = <<EOF
   {
    "ecs-cluster": "${aws_ecs_cluster.ecs_cluster.arn}",
    "ecs-dbt-task-definition": "${aws_ecs_task_definition.dbt_task.arn}",
    "ecs-soap-task-definition": "${aws_ecs_task_definition.soap_task.arn}",
    "ecs-task-private-subnet": "${data.terraform_remote_state.common.outputs.private_subnets[0]}",
    "ecs-task-security-group": "${module.ecs_task_security_group.security_group_id}"
   }
  EOF
}

module "lambda_function_run_dbt_task" {
  source = "terraform-aws-modules/lambda/aws"
  #version = "~> 2.0"

  function_name                     = "${local.prefixname}-run_dbt_task"
  description                       = "lambda function for runing dbt task"
  handler                           = "run_dbt_task.lambda_handler"
  runtime                           = "python3.8"
  cloudwatch_logs_retention_in_days = 1

  publish = true

  timeout = 600

  create_package         = false
  local_existing_package = "${var.buildpath}${var.run_dbt_task_zip}"

  attach_network_policy = true

  attach_policy_statements = true
  policy_statements = {
    secretsmanager = {
      effect    = "Allow",
      actions   = ["secretsmanager:GetSecretValue"],
      resources = [aws_secretsmanager_secret.secretsRDS.arn, aws_secretsmanager_secret.secretsECS.arn]
    },
    esc_cluster = {
      effect    = "Allow",
      actions   = ["ecs:RunTask"],
      resources = [aws_ecs_task_definition.dbt_task.arn]
    },
    pass_role = {
      effect    = "Allow",
      actions   = ["iam:PassRole"],
      resources = [aws_iam_role.iam_ecs_service_role.arn]
    }
  }

  environment_variables = {
    RDS_SECRET = aws_secretsmanager_secret.secretsRDS.name
    ECS_SECRET = aws_secretsmanager_secret.secretsECS.name
  }

  vpc_subnet_ids         = data.terraform_remote_state.common.outputs.private_subnets
  vpc_security_group_ids = [data.terraform_remote_state.common.outputs.sg_access_to_secretsmanager, module.ecs_task_security_group.security_group_id]

  tags = local.tags
}

module "lambda_function_run_soap_task" {
  source = "terraform-aws-modules/lambda/aws"
  #version = "~> 2.0"

  function_name                     = "${local.prefixname}-run_soap_task"
  description                       = "lambda function for running soap task"
  handler                           = "run_soap_task.lambda_handler"
  runtime                           = "python3.8"
  cloudwatch_logs_retention_in_days = 1

  publish = true

  timeout = 600

  create_package         = false
  local_existing_package = "${var.buildpath}${var.run_soap_task_zip}"

  attach_network_policy = true

  attach_policy_statements = true
  policy_statements = {
    secretsmanager = {
      effect    = "Allow",
      actions   = ["secretsmanager:GetSecretValue"],
      resources = [aws_secretsmanager_secret.secretsRDS.arn, aws_secretsmanager_secret.secretsECS.arn]
    },
    esc_cluster = {
      effect    = "Allow",
      actions   = ["ecs:RunTask"],
      resources = [aws_ecs_task_definition.soap_task.arn]
    },
    pass_role = {
      effect    = "Allow",
      actions   = ["iam:PassRole"],
      resources = [aws_iam_role.iam_ecs_service_role.arn]
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
    ECS_SECRET = aws_secretsmanager_secret.secretsECS.name
  }

  vpc_subnet_ids         = data.terraform_remote_state.common.outputs.private_subnets
  vpc_security_group_ids = [data.terraform_remote_state.common.outputs.sg_access_to_secretsmanager, module.ecs_task_security_group.security_group_id]

  tags = local.tags
}

