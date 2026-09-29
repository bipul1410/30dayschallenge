resource "aws_instance" "ec2_vpc1" {
  ami           = data.aws_ami.amazon_linux.id
  instance_type = "t2.micro"

  subnet_id = aws_subnet.subnet1.id

  associate_public_ip_address = true

  vpc_security_group_ids = [
    aws_security_group.sg1.id
  ]

  iam_instance_profile = aws_iam_instance_profile.ec2_ssm_profile.name

  key_name = "windows"

  tags = {
    Name = "EC2-VPC1"
  }
}

resource "aws_instance" "ec2_vpc2" {
  ami           = data.aws_ami.amazon_linux.id
  instance_type = "t2.micro"

  associate_public_ip_address = true

  subnet_id = aws_subnet.subnet2.id

  vpc_security_group_ids = [
    aws_security_group.sg2.id
  ]

  iam_instance_profile = aws_iam_instance_profile.ec2_ssm_profile.name

  key_name = "windows"

  tags = {
    Name = "EC2-VPC2"
  }
}


resource "aws_iam_role" "ec2_ssm_role_for_peering" {
  name = "EC2-SSM-Role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"

    Statement = [
      {
        Effect = "Allow"

        Principal = {
          Service = "ec2.amazonaws.com"
        }

        Action = "sts:AssumeRole"
      }
    ]
  })
}


resource "aws_iam_role_policy_attachment" "ssm" {
  role       = aws_iam_role.ec2_ssm_role_for_peering.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_instance_profile" "ec2_ssm_profile" {
  name = "EC2-SSM-Profile"
  role = aws_iam_role.ec2_ssm_role_for_peering.name
}


resource "aws_internet_gateway" "igw1" {
  vpc_id = aws_vpc.vpc1.id

  tags = {
    Name = "IGW-VPC1"
  }
}

resource "aws_internet_gateway" "igw2" {
  vpc_id = aws_vpc.vpc2.id

  tags = {
    Name = "IGW-VPC2"
  }
}

# =========================================================
# INTERNET ROUTE - VPC1
# =========================================================

resource "aws_route" "internet_route_vpc1" {
  route_table_id         = aws_route_table.rt1.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.igw1.id
}

# =========================================================
# INTERNET ROUTE - VPC2
# =========================================================

resource "aws_route" "internet_route_vpc2" {
  route_table_id         = aws_route_table.rt2.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.igw2.id
}