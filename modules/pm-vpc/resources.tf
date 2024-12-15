# Elastic IP
resource "aws_eip" "eip" {
  depends_on = [ module.pm-vpc ]
  domain = "vpc"
}

# NAT Gateway
resource "aws_nat_gateway" "nat" {
  depends_on = [ module.pm-vpc ]
  allocation_id = aws_eip.eip.id
  subnet_id     = module.pm-vpc.public_subnets[0]

  tags = {
    Name = "pm-nat"
  }
}

# Public Route Table
resource "aws_route_table" "public" {
  depends_on = [ module.pm-vpc ]
  vpc_id = module.pm-vpc.vpc_id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = module.pm-vpc.igw_id
  }

  tags = {
    Name = "public-rt"
  }
}

# Private Route Table
resource "aws_route_table" "private" {
  depends_on = [ module.pm-vpc ]
  vpc_id = module.pm-vpc.vpc_id  

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat.id
  }

  tags = {
    Name = "private-rt"
  }
}

resource "aws_security_group" "pm-sg" {
  depends_on = [ module.pm-vpc ]
  name        = "Allow SSH"
  description = "Allow SSH access to EC2 instances"
  vpc_id      = module.pm-vpc.vpc_id

  ingress {
    description = "Allow HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Allow HTTPS"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Allow SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Allow Port 8080"
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }


  egress {
    description = "Allow All outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "pm-sg"
  }
}
