resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"

  tags = {
    Name = "main-vpc"
  }
}

resource "aws_subnet" "public" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.1.0/24"
  map_public_ip_on_launch = true

  tags = {
    Name = "public-subnet"
  }
}

resource "aws_vpc" "sec" {
  cidr_block = "172.16.0.0/16"

  tags = {
    Name = "secondary-vpc"
  }
  provider = aws.sec
}

resource "aws_subnet" "private" {
  vpc_id     = aws_vpc.sec.id
  cidr_block = "172.16.1.0/24"

  tags = {
    Name = "private-subnet"
  }
  provider = aws.sec
}
#------------------------------peering-------------------------------------
resource "aws_vpc_peering_connection" "main" {
  peer_owner_id = data.aws_caller_identity.ja.account_id
  peer_region   = var.region_sec

  vpc_id      = aws_vpc.main.id
  peer_vpc_id = aws_vpc.sec.id
  auto_accept = false

  tags = {
    Name = "main-vpc-in-peering"
    Side = "Requester"
  }
}

resource "aws_vpc_peering_connection_accepter" "sec" {
  vpc_peering_connection_id = aws_vpc_peering_connection.main.id
  auto_accept               = true

  tags = {
    Name = "secondary-vpc-in-peering"
    Side = "Accepter"
  }
  provider = aws.sec
}
#-----------------------------route-----------------------------------
resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "vpc-main-ig"
  }
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }
  route {
    cidr_block                = aws_vpc.sec.cidr_block
    vpc_peering_connection_id = aws_vpc_peering_connection.main.id
  }

  tags = {
    Name = "route-table-vpc-main"
  }
}

resource "aws_route_table_association" "public" {
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.public.id
}

resource "aws_main_route_table_association" "main" {
  vpc_id         = aws_vpc.main.id
  route_table_id = aws_route_table.public.id
}
#--------------------------------------------------------------------
resource "aws_route_table" "private" {
  vpc_id = aws_vpc.sec.id

  route {
    cidr_block                = aws_vpc.main.cidr_block
    vpc_peering_connection_id = aws_vpc_peering_connection.main.id
  }
  tags = {
    Name = "route-table-vpc-sec"
  }
  provider = aws.sec
}

resource "aws_route_table_association" "private" {
  subnet_id      = aws_subnet.private.id
  route_table_id = aws_route_table.private.id

  provider = aws.sec
}

resource "aws_main_route_table_association" "sec" {
  vpc_id         = aws_vpc.sec.id
  route_table_id = aws_route_table.private.id

  provider = aws.sec
}
