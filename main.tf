provider "aws" {
  region = var.aws_region # First region
}

provider "aws" {
  alias  = "second_region"
  region = var.aws_second_region # Second region
}

resource "aws_vpc" "vpc" {
  cidr_block = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = local.vpc_name
  }
}

resource "aws_vpc" "vpc_second" {
  provider = aws.second_region
  cidr_block = var.vpc_cidr_second
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = local.vpc_name_second
  }
}

resource "aws_internet_gateway" "internet_gateway" {
  vpc_id = aws_vpc.vpc.id

  tags = {
    Name = local.internet_gateway_name
  }
}

resource "aws_internet_gateway" "internet_gateway_second" {
  provider = aws.second_region
  vpc_id = aws_vpc.vpc_second.id

  tags = {
    Name = local.internet_gateway_name_second
  }
}

resource "aws_subnet" "lytx_subnet" {
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = var.public_subnet_cidr               
  map_public_ip_on_launch = true   #remove 
  availability_zone       = var.az_names

  tags = {
    Name = join("-", [local.public_subnet_name, var.az_names])
  }
}

resource "aws_subnet" "lytx_subnet2" {
  provider                = aws.second_region
  vpc_id                  = aws_vpc.vpc_second.id
  cidr_block              = var.public_subnet_cidr_second              
  map_public_ip_on_launch = true    #remove
  availability_zone       = var.az_names_second

  tags = {
    Name = join("-", [local.public_subnet_name_second, var.az_names_second])
  }
}

# Create a security group for ping
resource "aws_security_group" "ping_group" {
  name        = local.asg_security_group_name
  description = "Security group to allow ping between instances"
  vpc_id      = aws_vpc.vpc.id

  # Allow ICMP ingress (ping)
  ingress {
    from_port   = -1
    to_port     = -1
    protocol    = "icmp"
    cidr_blocks = [var.public_subnet_cidr_second] # Assuming instances are within this VPC
  }

  # Allow inbound HTTPS traffic
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = [aws_vpc.vpc.cidr_block]
    description = "Allow HTTPS traffic from VPC"
  }

//remove 
  ingress {
    description = "SSH Connection"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  

  # Allow ICMP egress (ping)
  egress {
    from_port   = -1
    to_port     = -1
    protocol    = "icmp"
    cidr_blocks = [var.public_subnet_cidr_second]
  }

  egress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow HTTPS outbound traffic"
  }
}

# Create a security group for ping
resource "aws_security_group" "ping_group_second" {
  provider    = aws.second_region
  name        = local.asg_security_group_name_second
  description = "Security group to allow ping between instances second"
  vpc_id      = aws_vpc.vpc_second.id

  # Allow ICMP ingress (ping)
  ingress {
    from_port   = -1
    to_port     = -1
    protocol    = "icmp"
    cidr_blocks = [var.public_subnet_cidr] # Assuming instances are within this VPC
  }

  # Allow inbound HTTPS traffic
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = [aws_vpc.vpc_second.cidr_block]
    description = "Allow HTTPS traffic from VPC"
  }

  ingress {
    description = "SSH Connection"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Allow ICMP egress (ping)
  egress {
    from_port   = -1
    to_port     = -1
    protocol    = "icmp"
    cidr_blocks = [var.public_subnet_cidr]
  }

  egress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow HTTPS outbound traffic"
  }
}





resource "aws_iam_instance_profile" "dev-resources-iam-profile" {
name = "ec2_profile"
role = aws_iam_role.dev-resources-iam-role.name
}

resource "aws_iam_role" "dev-resources-iam-role" {
name        = "dev-ssm-role"
description = "The role for the developer resources EC2"
assume_role_policy = <<EOF
{
"Version": "2012-10-17",
"Statement": {
"Effect": "Allow",
"Principal": {"Service": "ec2.amazonaws.com"},
"Action": "sts:AssumeRole"
}
}
EOF
tags = {
stack = "test"
}
}

resource "aws_iam_role_policy_attachment" "dev-resources-ssm-policy" {
role       = aws_iam_role.dev-resources-iam-role.name
policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

# EC2 Instance 1
resource "aws_instance" "instance1" {
  ami                    = var.ami
  instance_type          = var.instance_type
  subnet_id              = aws_subnet.lytx_subnet.id
  vpc_security_group_ids = [aws_security_group.ping_group.id]
  associate_public_ip_address = true  #remove
  iam_instance_profile = aws_iam_instance_profile.dev-resources-iam-profile.name
}

resource "aws_iam_instance_profile" "dev-resources-iam-profile_second" {
  provider = aws.second_region  
  name = "ec2_profile-second"
  role = aws_iam_role.dev-resources-iam-role_second.name
}

resource "aws_iam_role" "dev-resources-iam-role_second" {
provider = aws.second_region
name        = "dev-ssm-role-second"
description = "The role for the developer resources EC2"
assume_role_policy = <<EOF
{
"Version": "2012-10-17",
"Statement": {
"Effect": "Allow",
"Principal": {"Service": "ec2.amazonaws.com"},
"Action": "sts:AssumeRole"
}
}
EOF
tags = {
stack = "test"
}
}

resource "aws_iam_role_policy_attachment" "dev-resources-ssm-policy_second" {
  provider = aws.second_region
  role       = aws_iam_role.dev-resources-iam-role_second.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

# EC2 Instance 2
resource "aws_instance" "instance2" {
  provider               = aws.second_region
  ami                    = var.ami2
  instance_type          = var.instance_type
  subnet_id              = aws_subnet.lytx_subnet2.id
  vpc_security_group_ids = [aws_security_group.ping_group_second.id]
  associate_public_ip_address = true     
  iam_instance_profile = aws_iam_instance_profile.dev-resources-iam-profile_second.name
}

# VPC Peering Connection (initiated from second region)
resource "aws_vpc_peering_connection" "peer" {
  provider = aws.second_region

  vpc_id        = aws_vpc.vpc_second.id
  peer_vpc_id   = aws_vpc.vpc.id
  peer_region   = var.aws_region
  auto_accept   = false
}

# Accept the VPC Peering Connection in us-east-1
resource "aws_vpc_peering_connection_accepter" "peer_accept" {
  vpc_peering_connection_id = aws_vpc_peering_connection.peer.id
  auto_accept               = true
}

# Creating Route Tables
resource "aws_route_table" "route_table_vpc1" {
  vpc_id = aws_vpc.vpc.id
  route {
    cidr_block = var.public_subnet_cidr_second
    vpc_peering_connection_id = aws_vpc_peering_connection.peer.id
  }

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.internet_gateway.id
  }
}

resource "aws_route_table" "route_table_vpc2" {
  provider = aws.second_region
  vpc_id = aws_vpc.vpc_second.id
  route {
    cidr_block = var.public_subnet_cidr
    vpc_peering_connection_id = aws_vpc_peering_connection.peer.id
  }
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.internet_gateway_second.id
  }

}

# Creating Route Table Association for VPC1
resource "aws_route_table_association" "association_vpc1" {
  subnet_id      = aws_subnet.lytx_subnet.id
  route_table_id = aws_route_table.route_table_vpc1.id
}

# Creating Route Table Association for VPC2
resource "aws_route_table_association" "association_vpc2" {
  provider = aws.second_region
  subnet_id      = aws_subnet.lytx_subnet2.id
  route_table_id = aws_route_table.route_table_vpc2.id
}
