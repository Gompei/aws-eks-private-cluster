########################################################
# VPC
########################################################
resource "aws_vpc" "vpc" {
  cidr_block = var.vpc_cidr_block
}

########################################################
# Internet Gateway
########################################################
resource "aws_internet_gateway" "internet_gateway" {
  vpc_id = aws_vpc.vpc.id
}

########################################################
# Nat Gateway
########################################################
resource "aws_eip" "nat" {
  count = 3
  vpc   = true
}
resource "aws_nat_gateway" "nat" {
  count         = 3
  subnet_id     = aws_subnet.public[count.index].id
  allocation_id = aws_eip.nat[count.index].id
}

########################################################
# Subnet
########################################################
data "aws_availability_zones" "available" {
}
# Public
resource "aws_subnet" "public" {
  count             = 3
  vpc_id            = aws_vpc.vpc.id
  availability_zone = data.aws_availability_zones.available.names[count.index]
  cidr_block        = cidrsubnet(var.vpc_cidr_block, 8, count.index)
  tags = {
    "kubernetes.io/role/elb" = 1
  }
}
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.vpc.id
}
resource "aws_route" "public" {
  destination_cidr_block = "0.0.0.0/0"
  route_table_id         = aws_route_table.public.id
  gateway_id             = aws_internet_gateway.internet_gateway.id
}
resource "aws_route_table_association" "public" {
  count          = 3
  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}

# Private
resource "aws_subnet" "private" {
  count             = 3
  vpc_id            = aws_vpc.vpc.id
  availability_zone = data.aws_availability_zones.available.names[count.index]
  cidr_block        = cidrsubnet(var.vpc_cidr_block, 8, length(aws_subnet.public) + count.index)
}
resource "aws_route_table" "private" {
  count  = 3
  vpc_id = aws_vpc.vpc.id
}
resource "aws_route" "private" {
  count                  = 3
  destination_cidr_block = "0.0.0.0/0"
  route_table_id         = aws_route_table.private[count.index].id
  nat_gateway_id         = aws_nat_gateway.nat[count.index].id
}
resource "aws_route_table_association" "private" {
  count          = 3
  subnet_id      = aws_subnet.private[count.index].id
  route_table_id = aws_route_table.private[count.index].id
}
