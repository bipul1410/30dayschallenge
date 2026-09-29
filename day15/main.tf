terraform {
  required_version = ">= 1.5.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }
}

# Configure the AWS Provider
provider "aws" {
  region = "us-east-1"
}

#
resource "aws_vpc" "vpc1" {
  cidr_block       = "10.0.0.0/16"
  instance_tenancy = "default"
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "main"
  }
}

resource "aws_route_table" "rt1" {
  vpc_id = aws_vpc.vpc1.id

   tags = {
    Name = "rt-vpc-a"
  }
}  

resource "aws_vpc" "vpc2" {
  cidr_block       = "10.2.0.0/16"
  instance_tenancy = "default"
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "secondary"
  }
}

resource "aws_route_table" "rt2" {
  vpc_id = aws_vpc.vpc2.id

   tags = {
    Name = "rt-vpc-b"
  }
}  

resource "aws_vpc_peering_connection" "peer" {
  vpc_id        = aws_vpc.vpc1.id
  peer_vpc_id   = aws_vpc.vpc2.id
  auto_accept   = true

  tags = {
    Name = "vpc-peering"
  }
}

resource "aws_vpc_peering_connection_accepter" "accepter" {
  vpc_peering_connection_id = aws_vpc_peering_connection.peer.id
  auto_accept               = true

  tags = {
    Name = "vpc-peering-accepter"
  }
}


# ==========================================
# 5. ROUTING ENTRIES (The "Glue")
# ==========================================

# Route in VPC A pointing to VPC B's CIDR via the peering connection
resource "aws_route" "route_a_to_b" {
  route_table_id            = aws_route_table.rt1.id
  destination_cidr_block    = aws_vpc.vpc2.cidr_block
  vpc_peering_connection_id = aws_vpc_peering_connection.peer.id
}

# Route in VPC B pointing to VPC A's CIDR via the peering connection
resource "aws_route" "route_b_to_a" {
  route_table_id            = aws_route_table.rt2.id
  destination_cidr_block    = aws_vpc.vpc1.cidr_block
  vpc_peering_connection_id = aws_vpc_peering_connection.peer.id
}
