# Let's plan what we want to do in this script:

# Terraform init - will download any required packages

# Set cloud provider - we inform terraform which cloud provider for it to speak to

### provider "aws" {

# Set the region
###  region = "eu-west-1"
# mind the indenation
# inputs like "region" and "provider" are case-sensitive
### }


# when we run "terraform init", it will create numerous files like '.terraform.lock.hcl'
# init with terraform
# What do we want to launch
# Automate the process of creating EC2 instance

# Name of the resource

## PROVISIONING AN INSTANCE ##
### resource "aws_instance" "karim_tf_app" { # within these curly brackets, we provide all the info for the instance

# Which AMI to use
## ami = "ami-07d8796a2b0f8d29c" # this works, but let's use a variable here instead:
###  ami = var.app_ami_id

# What type of instance
##  instance_type = "t2.micro"
###  instance_type = var.instance_type

# Do you want a public IP
##  associate_public_ip_address = true
###  associate_public_ip_address = var.public_ip_on

# What would you like to name your instance
##  tags = {
#    Name = "103a_karim_tf_app"
##  }
###  tags = var.tag

# Add a key pair
##  key_name =  "eng103a_karim"
###  key_name = var.key_pair
###}



provider "aws" {
  region = var.region
}

## PROVISIONING A VPC ##
resource "aws_vpc" "karim_tf_vpc" {
  cidr_block = "10.0.0.0/16"
  instance_tenancy = "default"
  tags = {
    Name = "karim_tf_vpc"
  }
}

## PROVISIONING A SUBNET ##
resource "aws_subnet" "karim_tf_subnet" {
  vpc_id            = aws_vpc.karim_tf_vpc.id
  cidr_block        = "10.0.1.0/24"
  tags = {
    Name = "karim_tf_subnet"
  }
}

## PROVISIONING A SECURITY GROUP ##
resource "aws_security_group" "karim_tf_sg" {
  name        = "karim_tf_sg"
  description = "Allow SSH"
  vpc_id      = aws_vpc.karim_tf_vpc.id
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
resource "aws_internet_gateway" "karim_tf_vpc_ig" {
  vpc_id = aws_vpc.karim_tf_vpc.id

  tags = {
    Name = "karim_tf_ig"
  }
}

## PROVISIONING A ROUTE TABLE ##
resource "aws_route_table" "karim_tf_vpc_rt" {
    vpc_id = aws_vpc.karim_tf_vpc.id

    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.karim_tf_vpc_ig.id
    }

    tags = {
        Name = "karim_tf_rt"
    }
}

## PROVISIONING A ROUTE TABLE ASSOCIATION ## 
resource "aws_route_table_association" "karim_tf_rt_association" {
    subnet_id = aws_subnet.karim_tf_subnet.id
    route_table_id = aws_route_table.karim_tf_vpc_rt.id
}

## PROVISIONING AN INSTANCE ## 

resource "aws_instance" "karim_tf_instance" {
  ami = var.app_ami_id
  instance_type = var.instance_type
  subnet_id = aws_subnet.karim_tf_subnet.id
  vpc_security_group_ids = [aws_security_group.karim_tf_sg.id]
  associate_public_ip_address = var.public_ip_on
  tags = var.tag
  key_name = var.key_pair
}

## LAUNCHING ANSIBLE CONTROLLER AMI ## 

resource "aws_instance" "karim_tf_ansible_instance" {
  ami = "ami-09d70526e4e406c99"
  instance_type = var.instance_type
  subnet_id = aws_subnet.karim_tf_subnet.id
  vpc_security_group_ids = [aws_security_group.karim_tf_sg.id]
  associate_public_ip_address = var.public_ip_on
  tags = var.tag
  key_name = var.key_pair
}