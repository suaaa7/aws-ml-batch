variable "azcount" {
  default = "1"
}
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
  count = var.azcount
  vpc_id = aws_vpc.vpc.id
  cidr_block = cidrsubnet(aws_vpc.vpc.cidr_block, 8, count.index)
  availability_zone = data.aws_availability_zones.current.names[count.index]
  map_public_ip_on_launch = false

  tags = {
    Name = "${var.project}-Private-subnet-${data.aws_availability_zones.current.names[count.index]}"
  }
}

# Public subnet for routing to the internet
resource "aws_subnet" "public" {
  count = var.azcount
  vpc_id = aws_vpc.vpc.id
  cidr_block = cidrsubnet(aws_vpc.vpc.cidr_block, 8, var.azcount + count.index)
  availability_zone = data.aws_availability_zones.current.names[count.index]
  map_public_ip_on_launch = true

  tags = {
    Name = "${var.project}-Public-subnet-${data.aws_availability_zones.current.names[count.index]}"
  }
}

# Internet Gateway
resource "aws_internet_gateway" "gateway" {
  vpc_id = aws_vpc.vpc.id

  tags = {
    Name = "${var.project}-Internet-Gateway"
  }
}

# Route to the internet
resource "aws_route" "internet_route" {
  route_table_id = aws_vpc.vpc.main_route_table_id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id = aws_internet_gateway.gateway.id
}

# Elastic IP for each AZ
resource "aws_eip" "eip" {
  count = var.azcount
  vpc = true
  depends_on = [aws_internet_gateway.gateway]

  tags = {
    Name = "${var.project}-EIP-${data.aws_availability_zones.current.names[count.index]}"
  }
}

# NAT gateway for each AZ
resource "aws_nat_gateway" "nat" {
  count = var.azcount
  allocation_id = element(aws_eip.eip.*.id, count.index)
  subnet_id = element(aws_subnet.public.*.id, count.index)
  depends_on = [aws_internet_gateway.gateway]

  tags = {
    Name = "${var.project}-Nat-${data.aws_availability_zones.current.names[count.index]}"
  }
}

# Route table for each private subnet
resource "aws_route_table" "private_route_table" {
  count = var.azcount
  vpc_id = aws_vpc.vpc.id

  tags = {
    Name = "${var.project}-Private-Route-Table-${data.aws_availability_zones.current.names[count.index]}"
  }
}

# Route traffic in each private subnet through the respective NAT gateway
resource "aws_route" "private_subnet_route" {
  count = var.azcount
  route_table_id = element(aws_route_table.private_route_table.*.id, count.index)
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id = element(aws_nat_gateway.nat.*.id, count.index)
}

# Associate each routing table with the respective subnet
resource "aws_route_table_association" "private_subnet_route_association" {
  count = var.azcount
  subnet_id = element(aws_subnet.private.*.id, count.index)
  route_table_id = element(aws_route_table.private_route_table.*.id, count.index)
}

output "vpc" {
  value = aws_vpc.vpc.id  
}

output "private_subnets" {
  value = [aws_subnet.private.*.id]
}
