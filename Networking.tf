##########################################
##  STA-PRODUCT-1 OODO App
##  Customer VPC 
##########################################
#  This will setup the network for a single
#  installation of OODO in the customers 
#  private VPC.
###########################################

resource "aws_security_group" "WebserverSG" {
  name        = "WebserverSG"
  description = "WebserverSG"
  vpc_id      = aws_vpc.CustomerVPC.id
  tags        = {
    "Name" = "ODOO-WS-SG"
  }

  ingress {
    from_port   = 8069
    to_port     = 8069
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "odooDBSG" {
  name        = "odooDBSG"
  description = "Allow connection from EC2 and out to any"
  vpc_id      = aws_vpc.CustomerVPC.id
  tags = {
    "Name" = "ODOO-DB-SG"
  }

  ingress {
    from_port       = 5432  #port from web to DB
    to_port         = 5432
    protocol        = "tcp"
    security_groups = [aws_security_group.WebserverSG.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_vpc" "CustomerVPC" {
  cidr_block           = var.VPC_CIDR
  enable_dns_hostnames = true
  enable_dns_support   = true
  tags = {
    "Name" = var.environment_name
  }
}

resource "aws_subnet" "PublicSubnet1" {
  vpc_id            = aws_vpc.CustomerVPC.id
  cidr_block        = var.PublicSubnet1
  availability_zone = "eu-west-2a"

  tags = {
    Name = "PublicSubnet1"
  }
}

resource "aws_subnet" "PublicSubnet2" {
  vpc_id            = aws_vpc.CustomerVPC.id
  cidr_block        = var.PublicSubnet2
  availability_zone = "eu-west-2b"

  tags = {
    Name = "PublicSubnet2"
  }
}

resource "aws_db_subnet_group" "main_db_subnet_group" {
  name       = "main_db_subnet_group"
  subnet_ids = [aws_subnet.PublicSubnet1.id, aws_subnet.PublicSubnet2.id]

  tags = {
    Name = "Subnet Group for DB"
  }
}

resource "aws_internet_gateway" "internet_gateway" {
  vpc_id = aws_vpc.CustomerVPC.id

  tags = {
    Name = var.environment_name
  }
}

data "aws_route_table" "selected" {
  vpc_id = aws_vpc.CustomerVPC.id
}

resource "aws_route" "route" {
  route_table_id         = data.aws_route_table.selected.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.internet_gateway.id
}

