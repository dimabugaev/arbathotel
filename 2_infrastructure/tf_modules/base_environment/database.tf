#RDS
module "rds_security_group" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "~> 4.0"

  name        = "${local.prefixname}-db-sg"
  description = "PostgreSQL security group"
  vpc_id      = data.terraform_remote_state.common.outputs.vpc_id

  # ingress
  ingress_with_source_security_group_id = [
    {
      from_port                = 5432
      to_port                  = 5432
      protocol                 = "tcp"
      description              = "PostgreSQL access from proxy"
      source_security_group_id = data.terraform_remote_state.common.outputs.sg_ssh_proxy
    },
    {
      from_port                = 5432
      to_port                  = 5432
      protocol                 = "tcp"
      description              = "PostgreSQL access from lambda API"
      source_security_group_id = module.lambda_api_security_group.security_group_id
    },
    {
      from_port                = 5432
      to_port                  = 5432
      protocol                 = "tcp"
      description              = "PostgreSQL access from lambda API"
      source_security_group_id = module.bnovo_extract_security_group.security_group_id
    },
    {
      from_port                = 5432
      to_port                  = 5432
      protocol                 = "tcp"
      description              = "PostgreSQL access from lambda API"
      source_security_group_id = module.banks_extract_security_group.security_group_id
    },
    {
      from_port                = 5432
      to_port                  = 5432
      protocol                 = "tcp"
      description              = "PostgreSQL access from lambda API"
      source_security_group_id = module.ecs_task_security_group.security_group_id
    },
  ]
  tags = local.tags
}


module "db" {
  source  = "terraform-aws-modules/rds/aws"
  version = "5.9.0"

  identifier = "${local.prefixname}-database"

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
  db_name  = "${var.environment}_arbathotel"
  username = var.environment

  create_random_password = true
  #password = var.db_password
  port = 5432

  multi_az               = false
  db_subnet_group_name   = data.terraform_remote_state.common.outputs.database_subnet_group
  vpc_security_group_ids = [module.rds_security_group.security_group_id]
  #  publicly_accessible = true

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
    },
    {
      name  = "password_encryption"
      value = "md5"
    }
  ]

  tags = local.tags
}

resource "aws_secretsmanager_secret" "secretsRDS" {
  name = "${local.prefixname}-db-instance"
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
