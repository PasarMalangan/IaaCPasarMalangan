# deploy vpc
module "pm-vpc" {
  
  source = "./modules/pm-vpc"
  env = var.env
  vpc_name = var.vpc_name
  cidr = var.cidr

  azs             = var.azs
  private_subnets = var.private_subnets
  public_subnets  = var.public_subnets

  enable_nat_gateway = var.enable_nat_gateway
  enable_vpn_gateway = var.enable_vpn_gateway
}


# deploy ec2
module "pm-instances" {

  source = "./modules/pm-instances"
  env = var.env

  ami_id = var.ami_id
  instance_type = var.instance_type
  key_name = var.key_name

  vpc_security_group_ids = [module.pm-vpc.pm_security_group_ids[0]]
  subnet_id = module.pm-vpc.public_subnet1_id
}


resource "aws_lb" "pm_nlb" {
  name               = "pm-nlb"
  internal           = false
  load_balancer_type = "network"
  security_groups    = [] # NLB tidak memerlukan security group
  subnets            = module.pm-vpc.merged_public_subnet_ids

  enable_deletion_protection = false

  tags = {
    Name = "pm-nlb"
  }
}

resource "aws_lb_target_group" "pm_nlb_tg" {
  name        = "pm-nlb-tg"
  port        = 80
  protocol    = "TCP"
  target_type = "instance"
  vpc_id      = module.pm-vpc.vpc_id

  health_check {
    protocol            = "TCP"
    interval            = 300
    healthy_threshold   = 5
    unhealthy_threshold = 10
    timeout             = 60
  }

  tags = {
    Name = "pm-nlb-tg"
  }
}

resource "aws_lb_listener" "pm_nlb_listener_http" {
  load_balancer_arn = aws_lb.pm_nlb.arn
  port              = 80
  protocol          = "TCP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.pm_nlb_tg.arn
  }
}

resource "aws_lb_listener" "pm_nlb_listener_https" {
  load_balancer_arn = aws_lb.pm_nlb.arn
  port              = 443
  protocol          = "TCP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.pm_nlb_tg.arn
  }
}


resource "aws_lb_target_group_attachment" "pm_nlb_tg_attachment" {
  count             = length(module.pm-instances.ids)  # Count the number of instances
  target_group_arn  = aws_lb_target_group.pm_nlb_tg.arn
  target_id         = module.pm-instances.ids[count.index]  # Access instance ID by index
}

# Define bucket names and their tags
locals {
  s3_buckets = {
    "iacremotestate" = {
      Name        = "iacremotestate"
      Environment = var.env
    },
    "identitypedagangprod" = {
      Name        = "identitypedagangprod"
      Environment = var.env
    },
    "assetspembeliprod" = {
      Name        = "assetspembeliprod"
      Environment = var.env
    },
    "assetspedagangprod" = {
      Name        = "assetspedagangprod"
      Environment = var.env
    },
    "assetsproductprod" = {
      Name        = "assetsproductprod"
      Environment = var.env
    }
  }
}

resource "aws_s3_bucket" "assets" {
  for_each = local.s3_buckets

  bucket        = each.key
  tags = each.value
}


resource "aws_dynamodb_table" "basic-dynamodb-table" {
  name           = "Pasarmalanganremotestate"
  billing_mode   = "PROVISIONED"
  read_capacity  = 20
  write_capacity = 20
  hash_key       = "LockId"

  attribute {
    name = "LockId"
    type = "S"
  }

  tags = {
    Name        = "Pasarmalanganremotestate"
    Environment = var.env
  }
}