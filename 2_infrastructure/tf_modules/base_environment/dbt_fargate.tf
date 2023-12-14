
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
        "name": "${local.prefixname}-dbt-container",
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
