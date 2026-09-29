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
  cidr_block           = "10.0.0.0/16"
  instance_tenancy     = "default"
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "VPC1-for-peering"
  }
}

resource "aws_route_table" "rt1" {
  vpc_id = aws_vpc.vpc1.id

  tags = {
    Name = "rt-vpc-a"
  }
}





resource "aws_subnet" "subnet1" {
  vpc_id            = aws_vpc.vpc1.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = "us-east-1a"

  tags = {
    Name = "subnet-vpc1"
  }
}

resource "aws_subnet" "subnet2" {
  vpc_id            = aws_vpc.vpc2.id
  cidr_block        = "10.2.1.0/24"
  availability_zone = "us-east-1a"

  tags = {
    Name = "subnet-vpc2"
  }
}



resource "aws_vpc" "vpc2" {
  cidr_block           = "10.2.0.0/16"
  instance_tenancy     = "default"
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "VPC2-for-peering"
  }

}
















resource "aws_route_table_association" "assoc1" {
  subnet_id      = aws_subnet.subnet1.id
  route_table_id = aws_route_table.rt1.id
}

resource "aws_route_table_association" "assoc2" {
  subnet_id      = aws_subnet.subnet2.id
  route_table_id = aws_route_table.rt2.id
}



resource "aws_route_table" "rt2" {
  vpc_id = aws_vpc.vpc2.id

  tags = {
    Name = "rt-vpc-b"
  }
}

resource "aws_vpc_peering_connection" "peer" {
  vpc_id      = aws_vpc.vpc1.id
  peer_vpc_id = aws_vpc.vpc2.id
  auto_accept = true

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

resource "aws_security_group" "sg1" {
  name   = "vpc1-ping-sg"
  vpc_id = aws_vpc.vpc1.id

  ingress {
    description = "Allow SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}


resource "aws_security_group" "sg2" {
  name   = "vpc2-ping-sg"
  vpc_id = aws_vpc.vpc2.id

  ingress {
    description = "Allow SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "SG-VPC2"
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
