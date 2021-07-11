provider "aws" {
  region = var.region_main
}

provider "aws" {
  region = var.region_sec
  alias  = "sec"
}

data "aws_region" "vpc_region_main" {}
data "aws_region" "vpc_region_secondary" { provider = aws.sec }
data "aws_caller_identity" "ja" {}

data "aws_ami" "ubuntu_server_main" {
  owners      = ["099720109477"]
  most_recent = true
  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }
}

data "aws_ami" "ubuntu_server_sec" {
  owners      = ["099720109477"]
  most_recent = true
  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }
  provider = aws.sec
}

resource "aws_security_group" "server_main" {
  name        = "main_security_group"
  description = "open  peering"
  vpc_id      = aws_vpc.main.id

  dynamic "ingress" {
    for_each = var.ports
    content {
      from_port   = ingress.value
      to_port     = ingress.value
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }
  }

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = [aws_vpc.sec.cidr_block]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "server_sec" {
  name        = "sec_security_group"
  description = "open  peering"
  vpc_id      = aws_vpc.sec.id

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  provider = aws.sec
}

resource "aws_instance" "server_main" {
  ami                         = data.aws_ami.ubuntu_server_main.id
  instance_type               = var.instance_type
  subnet_id                   = aws_subnet.public.id
  security_groups             = [aws_security_group.server_main.id]
  user_data                   = file("server_main.sh")
  key_name                    = var.pair_main
  associate_public_ip_address = true

  tags = {
    Name = "server-main"
  }
}

resource "aws_instance" "server_sec" {
  ami             = data.aws_ami.ubuntu_server_sec.id
  instance_type   = var.instance_type
  subnet_id       = aws_subnet.private.id
  security_groups = [aws_security_group.server_sec.id]

  tags = {
    Name = "server-sec"
  }
  provider = aws.sec
}
