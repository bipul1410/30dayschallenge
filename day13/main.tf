terraform {
  required_version = ">= 1.5.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

# variable "aws_region" {
#   description = "AWS region to deploy resources into"
#   type        = string
#   default     = "us-east-1"
# }

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t3.micro"
}

variable "instance_count" {
  description = "Number of instances/vpcs to create"
  type        = number
  default     = 1
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
  default     = "10.0.0.0/16"
}

# resource "aws_vpc" "main_vpcs" {
#   count             = var.instance_count
#   cidr_block        = var.vpc_cidr
#   vpc-id            = ""
#   subnet_ids       = [for i in range(var.instance_count) : cidrsubnet(var.vpc_cidr, 8, i)]
#   availability_zone = element(data.aws_availability_zones.available.names, count.index)
#   instance_tenancy  = "default"
#   enable_dns_support = true
#   enable_dns_hostnames = true

#   tags = {
#     Name = "main-vpc"
#   }
# }

data "aws_vpc" "data_vpcs" {
  filter {
    name   = "tag:Name"
    values = ["default"]
  }
}

data "aws_subnet" "data_subnets" {
  filter {
    name   = "tag:Name"
    values = ["subnet1a"]
  }
  vpc_id = data.aws_vpc.data_vpcs.id
}

data "aws_ami" "latest_amazon_linux" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}


resource "aws_instance" "main_instances" {
  ami           = data.aws_ami.latest_amazon_linux.id
  instance_type = var.instance_type
  subnet_id     = data.aws_subnet.data_subnets.id

  tags = {
    Name = "main-instance"
  }
}