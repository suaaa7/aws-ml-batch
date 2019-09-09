variable "project" {}

data "aws_availability_zones" "current" {}

# VPC
resource "aws_vpc" "vpc" {
  cidr_block = "10.0.0.0/16"

  tags = {
    Name = "${var.project}-vpc"
  }
}

# Private subnet for each AZ
resource "aws_subnet" "private" {
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = "10.0.0.0/24"
  availability_zone       = data.aws_availability_zones.current.names[0]
  map_public_ip_on_launch = false
}

# Public subnet for routing to the internet
resource "aws_subnet" "public" {
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = data.aws_availability_zones.current.names[1]
  map_public_ip_on_launch = true
}

# Internet Gateway
resource "aws_internet_gateway" "gateway" {
  vpc_id = aws_vpc.vpc.id
}

# Route to the internet
resource "aws_route" "internet_route" {
  route_table_id         = aws_vpc.vpc.main_route_table_id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.gateway.id
}

# Elastic IP for each AZ
resource "aws_eip" "eip" {
  vpc        = true
  depends_on = [aws_internet_gateway.gateway]
}

# NAT gateway for each AZ
resource "aws_nat_gateway" "nat" {
  allocation_id = aws_eip.eip.id
  subnet_id     = aws_subnet.public.id
  depends_on    = [aws_internet_gateway.gateway]
}

# Route table for each private subnet
resource "aws_route_table" "private_route_table" {
  vpc_id = aws_vpc.vpc.id
}

# Route traffic in each private subnet through the respective NAT gateway
resource "aws_route" "private_subnet_route" {
  route_table_id         = aws_route_table.private_route_table.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.nat.id
}

# Associate each routing table with the respective subnet
resource "aws_route_table_association" "private_subnet_route_association" {
  subnet_id      = aws_subnet.private.id
  route_table_id = aws_route_table.private_route_table.id
}

output "vpc" {
  value = aws_vpc.vpc.id
}

output "private_subnet" {
  value = aws_subnet.private.id
}
