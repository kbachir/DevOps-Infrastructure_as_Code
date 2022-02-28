provider "aws" {
  region = var.region
}

## PROVISIONING A VPC ##
resource "aws_vpc" "vpc" {
  cidr_block = "10.0.0.0/16"
  instance_tenancy = "default"
  tags = {
    Name = "karim_tf_vpc"
  }
}

## PROVISIONING A SUBNET #1 ##
resource "aws_subnet" "subnet1" {
  vpc_id = aws_vpc.vpc.id
  cidr_block = "10.0.1.0/24"
  tags = {
    Name = "karim_tf_subnet1"
  }
  availability_zone = "eu-west-1a"
}

## PROVISIONING A SUBNET #2 ##
resource "aws_subnet" "subnet2" {
  vpc_id = aws_vpc.vpc.id
  cidr_block = "10.0.2.0/24"
  tags = {
    Name = "karim_tf_subnet2"
  }
  availability_zone = "eu-west-1b"
}

## PROVISIONING A SUBNET #3 ##
resource "aws_subnet" "subnet3" {
  vpc_id = aws_vpc.vpc.id
  cidr_block = "10.0.3.0/24"
  tags = {
    Name = "karim_tf_subnet3"
  }
  availability_zone = "eu-west-1c"
}

## PROVISIONING A SECURITY GROUP ##
resource "aws_security_group" "open_security_group" {
  name        = "karim_tf_sg"
  description = "Allow SSH"
  vpc_id      = aws_vpc.vpc.id
  tags = {
    Name = "karim_tf_sg"
  }

  ingress {
    description      = "My IP only"
    from_port        = 22
    to_port          = 22
    protocol         = "TCP"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  ingress {
    description      = "app"
    from_port        = 3000
    to_port          = 3000
    protocol         = "TCP"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  ingress {
    description      = "HTTP"
    from_port        = 80
    to_port          = 80
    protocol         = "TCP"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
}

## PROVISIONING AN INTERNET GATEWAY ##
resource "aws_internet_gateway" "internet_gateway" {
  vpc_id = aws_vpc.vpc.id

  tags = {
    Name = "karim_tf_ig"
  }
}

## PROVISIONING A ROUTE TABLE ##
resource "aws_route_table" "route_table" {
    vpc_id = aws_vpc.vpc.id

    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.internet_gateway.id
    }

    tags = {
        Name = "karim_tf_rt"
    }
}

## PROVISIONING A ROUTE TABLE ASSOCIATION ## 
resource "aws_route_table_association" "route_table_association" {
    subnet_id = aws_subnet.subnet1.id
    route_table_id = aws_route_table.route_table.id
}