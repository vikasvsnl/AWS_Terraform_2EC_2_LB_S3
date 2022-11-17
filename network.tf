

# Declare the data source
data "aws_availability_zones" "available" {
  state = "available"
}


############################################################
# RESOURCES
############################################################

# VPC

resource "aws_vpc" "test_vpc" {
  cidr_block           = var.vpc_cidr_block
  enable_dns_hostnames = var.enable_dns_hostname
  tags = {
    name = "test_vpc"
  }
}

# subnets
resource "aws_subnet" "subnet1" {
  cidr_block = var.vpc_subnets[0]
  vpc_id     = aws_vpc.test_vpc.id
  map_public_ip_on_launch = var.map_public_ip_on_launch
  availability_zone = data.aws_availability_zones.available.names[0]
  tags = {
    "name" = "vpc_subnet1"
  }

}

resource "aws_subnet" "subnet2" {
  cidr_block = var.vpc_subnets[1]
  vpc_id     = aws_vpc.test_vpc.id
  map_public_ip_on_launch = var.map_public_ip_on_launch
  availability_zone = data.aws_availability_zones.available.names[1]
  tags = {
    "name" = "vpc_subnet2"
  }

}

# Internet Gateway

resource "aws_internet_gateway" "IGW" {
  vpc_id = aws_vpc.test_vpc.id
  tags = {
    "name" = "vpc_IGW"
  }
}

# Routing table

resource "aws_route_table" "route_table1" {
  vpc_id = aws_vpc.test_vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.IGW.id
  }
}

# association between route table & subnet

resource "aws_route_table_association" "route_table_subnet1" {
  subnet_id      = aws_subnet.subnet1.id
  route_table_id = aws_route_table.route_table1.id
}

resource "aws_route_table_association" "route_table_subnet2" {
  subnet_id      = aws_subnet.subnet2.id
  route_table_id = aws_route_table.route_table1.id
}

# security Group for EC2 machine

resource "aws_security_group" "allow_http" {
  name        = "allow_protocols"
  description = "Allow  inbound traffic"
  vpc_id      = aws_vpc.test_vpc.id

  ingress {
    description      = " from outside VPC"
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    cidr_blocks      = ["10.0.0.0/16"]
   # ipv6_cidr_blocks = ["::/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    # ipv6_cidr_blocks = ["::/0"]
  }
}

# security Group for loadbalancer


resource "aws_security_group" "alb_sg" {
  name        = "lb_sg"
  description = "Allow  inbound traffic"
  vpc_id      = aws_vpc.test_vpc.id

  ingress {
    description      = " from outside VPC"
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
   # ipv6_cidr_blocks = ["::/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    # ipv6_cidr_blocks = ["::/0"]
  }
}
