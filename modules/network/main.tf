locals {
  subnet_configuration = {
    for index, availability_zone in var.availability_zones : availability_zone => {
      index               = index
      public_cidr_block   = var.public_subnet_cidr_blocks[index]
      private_cidr_block  = var.private_subnet_cidr_blocks[index]
      public_subnet_name  = format("%s-public-%s", var.name_prefix, availability_zone)
      private_subnet_name = format("%s-private-%s", var.name_prefix, availability_zone)
      private_route_name  = format("%s-private-rt-%s", var.name_prefix, availability_zone)
    }
  }
}

resource "aws_vpc" "this" {
  cidr_block           = var.vpc_cidr_block
  enable_dns_support   = var.enable_dns_support
  enable_dns_hostnames = var.enable_dns_hostnames

  tags = merge(var.tags, var.vpc_tags, {
    Name = format("%s-vpc", var.name_prefix)
  })
}

resource "aws_internet_gateway" "this" {
  vpc_id = aws_vpc.this.id

  tags = merge(var.tags, var.internet_gateway_tags, {
    Name = format("%s-igw", var.name_prefix)
  })
}

resource "aws_subnet" "public" {
  for_each = local.subnet_configuration

  vpc_id                  = aws_vpc.this.id
  cidr_block              = each.value.public_cidr_block
  availability_zone       = each.key
  map_public_ip_on_launch = var.map_public_ip_on_launch

  tags = merge(var.tags, var.public_subnet_tags, {
    Name = each.value.public_subnet_name
    Tier = "public"
  })
}

resource "aws_subnet" "private" {
  for_each = local.subnet_configuration

  vpc_id            = aws_vpc.this.id
  cidr_block        = each.value.private_cidr_block
  availability_zone = each.key

  tags = merge(var.tags, var.private_subnet_tags, {
    Name = each.value.private_subnet_name
    Tier = "private"
  })
}

resource "aws_eip" "nat" {
  domain = "vpc"

  tags = merge(var.tags, var.nat_gateway_tags, {
    Name = format("%s-nat-eip", var.name_prefix)
  })

  depends_on = [aws_internet_gateway.this]
}

resource "aws_nat_gateway" "this" {
  allocation_id = aws_eip.nat.id
  subnet_id     = aws_subnet.public[var.availability_zones[0]].id

  tags = merge(var.tags, var.nat_gateway_tags, {
    Name = format("%s-nat", var.name_prefix)
  })

  depends_on = [aws_internet_gateway.this]
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.this.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.this.id
  }

  tags = merge(var.tags, var.route_table_tags, {
    Name = format("%s-public-rt", var.name_prefix)
  })
}

resource "aws_route_table_association" "public" {
  for_each = aws_subnet.public

  subnet_id      = each.value.id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table" "private" {
  for_each = local.subnet_configuration

  vpc_id = aws_vpc.this.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.this.id
  }

  tags = merge(var.tags, var.route_table_tags, {
    Name = each.value.private_route_name
  })
}

resource "aws_route_table_association" "private" {
  for_each = aws_subnet.private

  subnet_id      = each.value.id
  route_table_id = aws_route_table.private[each.key].id
}

resource "aws_security_group" "web" {
  name        = format("%s-web-sg", var.name_prefix)
  description = "Allow HTTP and HTTPS traffic to web servers"
  vpc_id      = aws_vpc.this.id

  ingress {
    description = "Allow HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = var.web_ingress_cidr_blocks
  }

  ingress {
    description = "Allow HTTPS"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = var.web_ingress_cidr_blocks
  }

  egress {
    description      = "Allow all outbound traffic"
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = merge(var.tags, var.security_group_tags, {
    Name = format("%s-web-sg", var.name_prefix)
  })
}
