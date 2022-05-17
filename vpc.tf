

terraform {
  backend "s3" {
    bucket         = "tfstatefilebucket88"
    key            = "tfstatefiles/terraform.tfstate"
    region         = "us-east-2"
    dynamodb_table = "lockefile"
  }
}


resource "aws_vpc" "Main" {
  cidr_block       = var.main_vpc_cidr
  instance_tenancy = "default"

  tags = {
    Name = var.appname

  }
}

resource "aws_internet_gateway" "IGW" {
  vpc_id = aws_vpc.Main.id
  tags = {
    Name = var.appname

  }
}

resource "aws_subnet" "publicsubnets" {
  vpc_id     = aws_vpc.Main.id
  cidr_block = var.public_subnets
  tags = {
    Name = var.appname

  }
}

resource "aws_subnet" "privatesubnets" {
  vpc_id     = aws_vpc.Main.id
  cidr_block = var.private_subnets
  tags = {
    Name = var.appname

  }
}

resource "aws_route_table" "PublicRT" {
  vpc_id = aws_vpc.Main.id
  route {
    cidr_block = var.cicdr
    gateway_id = aws_internet_gateway.IGW.id
  }
  tags = {
    Name = var.appname

  }
}

resource "aws_route_table" "PrivateRT" {
  vpc_id = aws_vpc.Main.id
  route {
    cidr_block     = var.cicdr
    nat_gateway_id = aws_nat_gateway.NATgw.id
  }
  tags = {
    Name = var.appname

  }
}


resource "aws_route_table_association" "PublicRTassociation" {
  subnet_id      = aws_subnet.publicsubnets.id
  route_table_id = aws_route_table.PublicRT.id

}

resource "aws_route_table_association" "PrivateRTassociation" {
  subnet_id      = aws_subnet.privatesubnets.id
  route_table_id = aws_route_table.PrivateRT.id
}

resource "aws_eip" "nateIP" {
  vpc = true
  tags = {
    Name = var.appname

  }
}

resource "aws_nat_gateway" "NATgw" {
  allocation_id = aws_eip.nateIP.id
  subnet_id     = aws_subnet.publicsubnets.id
  tags = {
    Name = var.appname

  }
}


##################

resource "aws_network_acl" "My_VPC_Security_ACL" {
  vpc_id     = aws_vpc.Main.id
  subnet_ids = [aws_subnet.publicsubnets.id]
  # allow ingress port 22
  ingress {
    protocol   = "tcp"
    rule_no    = 100
    action     = "allow"
    cidr_block = var.cicdr
    from_port  = 22
    to_port    = 22
  }

  # allow ingress port 80 
  ingress {
    protocol   = "tcp"
    rule_no    = 200
    action     = "allow"
    cidr_block = var.cicdr
    from_port  = 80
    to_port    = 80
  }

  # allow ingress ephemeral ports 
  ingress {
    protocol   = "tcp"
    rule_no    = 300
    action     = "allow"
    cidr_block = var.cicdr
    from_port  = 1024
    to_port    = 65535
  }

  # allow egress port 22 
  egress {
    protocol   = "tcp"
    rule_no    = 100
    action     = "allow"
    cidr_block = var.cicdr
    from_port  = 22
    to_port    = 22
  }

  # allow egress port 80 
  egress {
    protocol   = "tcp"
    rule_no    = 200
    action     = "allow"
    cidr_block = var.cicdr
    from_port  = 80
    to_port    = 80
  }

  # allow egress ephemeral ports
  egress {
    protocol   = "tcp"
    rule_no    = 300
    action     = "allow"
    cidr_block = var.cicdr
    from_port  = 1024
    to_port    = 65535
  }
  tags = {
    Name = var.appname
  }
}



output "vpc-id" {
  description = "The private vpc id."
  value       = aws_vpc.Main.id

}

























