# Creates an AWS VPC with DNS support and hostnames enabled
resource "aws_vpc" "vpc" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    # names vpc
    Name = "${var.vpc_name}"
  }
}

# Defines a subnet within the created VPC
resource "aws_subnet" "subnet" {
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = var.subnet_cidr
  availability_zone       = var.availability_zone
  map_public_ip_on_launch = true # gives public ip

  tags = {
    # names subnet
    Name = "${var.subnet_name}"
  }
}