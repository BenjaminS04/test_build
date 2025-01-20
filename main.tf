terraform { #sets required providers and versions
  required_version = "1.8.5"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.72.1"
    }
  }


}

provider "aws" {
  region = var.region # Update with your desired AWS region
}

module "vpc" { # vpc for resouces
  source            = "./modules/vpc"
  vpc_cidr          = "10.0.0.0/16"
  vpc_name          = "vpc"
  subnet_cidr       = "10.0.0.0/24"
  subnet_name       = "${var.environment}-subnet"
  availability_zone = "${var.region}a"
}

module "security_group" { # security group module for ec2
  vpc_id              = module.vpc.vpc_id
  source              = "./modules/sg"
  security_group_name = "${var.environment}-security-group"
  vpn_ip              = var.vpn_ip
}

module "internet_gateway" { # internet gateway module for ec2
  source       = "./modules/igw"
  vpc_id       = module.vpc.vpc_id
  subnet_id    = module.vpc.subnet_id
  gateway_name = "${var.environment}-gateway"

}

module "ec2" { # ec2 module
  for_each             = local.instances
  source               = "./modules/ec2"
  ami                  = var.ami
  instance_type        = var.instance_type
  key_name             = "test"
  security_group_id    = module.security_group.sg_id
  subnet_id            = module.vpc.subnet_id
  instance_name        = "${each.key}-instance-${var.environment}"
  iam_instance_profile = "${each.key}-EC2InstanceProfile"
  additional_user_data = each.value
  each_key             = each.key
}

module "iam_policies" { # policy module for ec2 iam role
  source = "./modules/policies"
}

module "sns" {
  source            = "./modules/sns"
  environment       = var.environment
  sns_topic_name    = "monitoring-app-alerts"
  sns_subscriptions = var.sns_subscriptions
}