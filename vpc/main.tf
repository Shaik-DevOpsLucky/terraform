# Configure the provider
provider "aws" {
  region = var.region
}

# Create VPC
resource "aws_vpc" "main_vpc" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags = merge(var.tags, {
    Name = "${var.environment} VPC"
  })
}

# Create public subnets
resource "aws_subnet" "public_subnet_1" {
  vpc_id                  = aws_vpc.main_vpc.id
  cidr_block              = var.public_subnet_cidrs[0]
  map_public_ip_on_launch = true
  availability_zone       = var.availability_zones[0]

  tags = merge(var.tags, {
    Name                     = "${var.environment} Public Subnet 1",
    "kubernetes.io/role/elb" = "1"
  })
}

resource "aws_subnet" "public_subnet_2" {
  vpc_id                  = aws_vpc.main_vpc.id
  cidr_block              = var.public_subnet_cidrs[1]
  map_public_ip_on_launch = true
  availability_zone       = var.availability_zones[1]

  tags = merge(var.tags, {
    Name                     = "${var.environment} Public Subnet 2",
    "kubernetes.io/role/elb" = "1"
  })
}

# Create private subnets
resource "aws_subnet" "private_subnet_1" {
  vpc_id            = aws_vpc.main_vpc.id
  cidr_block        = var.private_subnet_cidrs[0]
  availability_zone = var.availability_zones[0]

  tags = merge(var.tags, {
    Name                              = "${var.environment} Private Subnet 1",
    "kubernetes.io/role/internal-elb" = "1"
  })
}

resource "aws_subnet" "private_subnet_2" {
  vpc_id            = aws_vpc.main_vpc.id
  cidr_block        = var.private_subnet_cidrs[1]
  availability_zone = var.availability_zones[1]

  tags = merge(var.tags, {
    Name                              = "${var.environment} Private Subnet 2",
    "kubernetes.io/role/internal-elb" = "1"
  })
}

# Create Internet Gateway
resource "aws_internet_gateway" "internet_gateway" {
  vpc_id = aws_vpc.main_vpc.id

  tags = merge(var.tags, {
    Name = "${var.environment} Internet Gateway"
  })
}

# Elastic IP for NAT Gateway
resource "aws_eip" "nat_eip" {
  tags = merge(var.tags, {
    Name = "${var.environment} NAT EIP"
  })
}

# Create NAT Gateway in public subnet
resource "aws_nat_gateway" "nat_gateway" {
  allocation_id = aws_eip.nat_eip.id
  subnet_id     = aws_subnet.public_subnet_1.id

  tags = merge(var.tags, {
    Name = "${var.environment} NAT Gateway"
  })
}

# Create Route Table for public subnets
resource "aws_route_table" "public_route_table" {
  vpc_id = aws_vpc.main_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.internet_gateway.id
  }

  route {
    cidr_block = var.vpc_cidr
    gateway_id = "local"
  }

  tags = merge(var.tags, {
    Name = "${var.environment} Public Route Table"
  })
}

# Create Route Table for private subnets
resource "aws_route_table" "private_route_table" {
  vpc_id = aws_vpc.main_vpc.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat_gateway.id
  }

  route {
    cidr_block = var.vpc_cidr
    gateway_id = "local"
  }

  tags = merge(var.tags, {
    Name = "${var.environment} Private Route Table"
  })
}

# Associate route tables with subnets
resource "aws_route_table_association" "public_association_1" {
  subnet_id      = aws_subnet.public_subnet_1.id
  route_table_id = aws_route_table.public_route_table.id
}

resource "aws_route_table_association" "public_association_2" {
  subnet_id      = aws_subnet.public_subnet_2.id
  route_table_id = aws_route_table.public_route_table.id
}

resource "aws_route_table_association" "private_association_1" {
  subnet_id      = aws_subnet.private_subnet_1.id
  route_table_id = aws_route_table.private_route_table.id
}

resource "aws_route_table_association" "private_association_2" {
  subnet_id      = aws_subnet.private_subnet_2.id
  route_table_id = aws_route_table.private_route_table.id
}

# Security group for EC2 and EKS
resource "aws_security_group" "eks_sg" {
  vpc_id = aws_vpc.main_vpc.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(var.tags, {
    Name = "${var.environment} EKS Security Group"
  })
}

# Outputs
output "vpc_id" {
  value       = aws_vpc.main_vpc.id
  description = "VPC ID"
}

output "public_subnet_1_id" {
  value       = aws_subnet.public_subnet_1.id
  description = "Public Subnet 1 ID"
}

output "private_subnet_1_id" {
  value       = aws_subnet.private_subnet_1.id
  description = "Private Subnet 1 ID"
}

output "private_subnet_2_id" {
  value       = aws_subnet.private_subnet_2.id
  description = "Private Subnet 1 ID"
}

output "nat_gateway_id" {
  value       = aws_nat_gateway.nat_gateway.id
  description = "NAT Gateway ID"
}
