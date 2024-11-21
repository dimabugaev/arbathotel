#VPS + Subnets + SG + NAT

module "vpc" {
  source = "terraform-aws-modules/vpc/aws"
  #version = "2.77.0"

  name            = "main-vpc"
  cidr            = "192.168.0.0/16"
  azs             = slice(data.aws_availability_zones.available.names, 0, 2)
  public_subnets  = ["192.168.1.0/24", "192.168.2.0/24"]
  private_subnets = ["192.168.11.0/24", "192.168.12.0/24"]
  #database_subnets       = ["192.168.21.0/24", "192.168.22.0/24"]

  enable_dns_hostnames = true

  enable_dns_support = true

  manage_default_network_acl    = false
  manage_default_security_group = false
  manage_default_route_table    = false

  #enable_nat_gateway = true
  #single_nat_gateway = true

  #create_database_subnet_group = true
  #create_database_subnet_route_table     = true
  #create_database_internet_gateway_route = true

  #enable_secretsmanager_endpoint              = true
  #secretsmanager_endpoint_private_dns_enabled = true
  #secretsmanager_endpoint_security_group_ids  = [module.secrets_endpoints_security_group.security_group_id]
  #secretsmanager_endpoint_subnet_ids = private_subnets

  tags = local.tags
}

# module "vpc_endpoints" {

#   source = "terraform-aws-modules/vpc/aws//modules/vpc-endpoints"
#   vpc_id = module.vpc.vpc_id

#   endpoints = {
#     secretsmanager = {
#       service             = "secretsmanager"
#       private_dns_enabled = true
#       subnet_ids          = module.vpc.private_subnets
#       security_group_ids  = [module.secrets_endpoints_security_group.security_group_id]
#     },
#   }

#   tags = local.tags
# }

resource "aws_db_subnet_group" "default" {
  name       = "main-db-subnets-group"
  subnet_ids = module.vpc.private_subnets

  tags = local.tags
}

# module "secrets_endpoints_security_group" {
#   source = "terraform-aws-modules/security-group/aws"
#   #version = "~> 4.0"

#   name        = "main-endpoint-sg-to-secretsmanager"
#   description = "SG endpoints to secrets db"
#   vpc_id      = module.vpc.vpc_id

#   computed_ingress_with_source_security_group_id = [
#     {
#       rule                     = "all-tcp"
#       description              = "Allow access from API call"
#       source_security_group_id = module.secretsmanager_access_security_group.security_group_id
#     },
#   ]
#   number_of_computed_ingress_with_source_security_group_id = 1

#   egress_rules = ["all-all"]

#   tags = local.tags
# }

module "secretsmanager_access_security_group" {
  source = "terraform-aws-modules/security-group/aws"
  #version = "~> 4.0"

  name        = "secretsmanager-access-sg"
  description = "SG for get access to secretsmanager VPC"
  vpc_id      = module.vpc.vpc_id

  egress_rules = ["all-all"]

  tags = local.tags
}

module "nat" {
  source  = "int128/nat-instance/aws"
  version = "2.1.0"
  #version = "~> 4.0"
  key_name = "arbat-developer-key"

  name                        = "main-nat"
  vpc_id                      = module.vpc.vpc_id
  public_subnet               = module.vpc.public_subnets[0]
  private_subnets_cidr_blocks = module.vpc.private_subnets_cidr_blocks
  private_route_table_ids     = module.vpc.private_route_table_ids
}

resource "aws_eip" "nat" {
  network_interface = module.nat.eni_id
  tags = {
    "Name" = "nat-instance-main"
  }
}

resource "aws_security_group_rule" "nat_ssh" {
  security_group_id = module.nat.sg_id
  type              = "ingress"
  cidr_blocks       = ["0.0.0.0/0"]
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
}

resource "aws_key_pair" "developer" {
  key_name   = "arbat-developer-key"
  public_key = var.arbat_pub_key
}
