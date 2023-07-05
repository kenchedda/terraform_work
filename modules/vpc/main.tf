# create vpc
resource "aws_vpc" "vpc" {
  cidr_block              = var.vpc_cidr
  instance_tenancy        = "default"
  enable_dns_hostnames    = true
  enable_dns_support  =  true

  tags      = {
    Name    = "${var.PROJECT_NAME}-vpc"
  }
}

# create internet gateway and attach it to vpc
resource "aws_internet_gateway" "internet_gateway" {
  vpc_id    = aws_vpc.vpc.id

  tags      = {
    Name    = "${var.PROJECT_NAME}-igw"
  }
}

# use data source to get all avalablility zones in region
data "aws_availability_zones" "available_zones" {}


# create public subnets
resource "aws_subnet" "pub-sub" {
  count                   = var.pub_sub_count  
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = "10.0.${10 + count.index}.0/24"
  availability_zone       = data.aws_availability_zones.available_zones.names[count.index]
  map_public_ip_on_launch = true

  tags      = {
    Name    = "pub-sub-${count.index}"
  }
}

# create route table and add public route
resource "aws_route_table" "public_route_table" {
  vpc_id       = aws_vpc.vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.internet_gateway.id
  }

  tags       = {
    Name     = "Public-RT"
  }
}

# associate public subnet pub-sub-1-a to "public route table"
resource "aws_route_table_association" "pub-sub-1-a_route_table_association" {
   count          = var.pub_sub_count 
  subnet_id           = aws_subnet.pub-sub.*.id[count.index]
  route_table_id      = aws_route_table.public_route_table.id
}


resource "aws_eip" "eip" {
  vpc = true
}

resource "aws_nat_gateway" "nat" { 
 
  allocation_id = aws_eip.eip.id
  subnet_id     = aws_subnet.pub-sub[0].id

}


# create private subnets
resource "aws_subnet" "pri-sub" {
  count                   = var.db_sub_count  
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = "10.0.${20 + count.index}.0/24"
  availability_zone       = data.aws_availability_zones.available_zones.names[count.index]
  map_public_ip_on_launch = false

  tags      = {
    Name    = "pri-sub-${count.index}"
  }
}

# create route table and add private route
resource "aws_route_table" "pri_route_table" {
  vpc_id       = aws_vpc.vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id         = aws_nat_gateway.nat.id
  }

  tags       = {
    Name     = "pri-RT"
  }
}

# associate private subnet to "privateroute table"
resource "aws_route_table_association" "pri_sub_route_table_association" {
   count          = var.pri_sub_count 
  subnet_id           = aws_subnet.pri-sub.*.id[count.index]
  route_table_id      = aws_route_table.pri_route_table.id
}




resource "aws_subnet" "db-sub" {
  count                   = var.db_sub_count  
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = "10.0.${30 + count.index}.0/24"
  availability_zone       = data.aws_availability_zones.available_zones.names[count.index]
  map_public_ip_on_launch = false

  tags      = {
    Name    = "db-sub-${count.index}"
  }
}

# create route table and add private route
resource "aws_route_table" "db_route_table" {
  vpc_id       = aws_vpc.vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id         = aws_nat_gateway.nat.id
  }

  tags       = {
    Name     = "db-RT"
  }
}

# associate private subnet to "privateroute table"
resource "aws_route_table_association" "db_sub_route_table_association" {
   count          = var.db_sub_count 
  subnet_id           = aws_subnet.db-sub.*.id[count.index]
  route_table_id      = aws_route_table.db_route_table.id
}

# create security group for the application load balancer
resource "aws_security_group" "alb_sg" {
  name        = "alb security group"
  description = "enable http/https access on port 80/443"
  vpc_id      = aws_vpc.vpc.id

  ingress {
    description = "http access"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "https access"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = -1
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "ALB_SG"
  }
}

# create security group for the Client
resource "aws_security_group" "web_sg" {
  name        = "client_sg"
  description = "enable http/https access on port 80 for elb sg"
  vpc_id      = aws_vpc.vpc.id

  ingress {
    description     = "http access"
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.alb_sg.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = -1
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "Client_sg"
  }
}

# create security group for the Database
resource "aws_security_group" "db_sg" {
  name        = "db_sg"
  description = "enable mysql access on port 3305 from client-sg"
  vpc_id      = aws_vpc.vpc.id

  ingress {
    description     = "mysql access"
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    security_groups = [aws_security_group.web_sg.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = -1
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "Database_sg"
  }
}

# create security group for the Bastion host or Jump server
resource "aws_security_group" "jump_sg" {
  name        = "jump_sg"
  description = "enable ssh access on port 22 "
  vpc_id      = aws_vpc.vpc.id

  ingress {
    description     = "ssh access"
    from_port       = 22
    to_port         = 22
    protocol        = "tcp"
    cidr_blocks = ["0.0.0.0/0"]

  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = -1
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "jump_sg"
  }
}

