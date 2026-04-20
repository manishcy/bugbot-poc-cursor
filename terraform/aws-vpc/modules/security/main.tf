resource "aws_security_group" "web" {
  name        = "${var.name_prefix}-web-sg"
  description = "Security group for web servers. Allows HTTP/HTTPS ingress and all egress."
  vpc_id      = var.vpc_id

  tags = merge(var.tags, {
    Name = "${var.name_prefix}-web-sg"
  })
}

resource "aws_vpc_security_group_ingress_rule" "http" {
  for_each = toset(var.ingress_cidr_blocks)

  security_group_id = aws_security_group.web.id
  description       = "Allow HTTP from ${each.value}"
  cidr_ipv4         = each.value
  from_port         = 80
  to_port           = 80
  ip_protocol       = "tcp"

  tags = merge(var.tags, {
    Name = "${var.name_prefix}-web-http"
  })
}

resource "aws_vpc_security_group_ingress_rule" "https" {
  for_each = toset(var.ingress_cidr_blocks)

  security_group_id = aws_security_group.web.id
  description       = "Allow HTTPS from ${each.value}"
  cidr_ipv4         = each.value
  from_port         = 443
  to_port           = 443
  ip_protocol       = "tcp"

  tags = merge(var.tags, {
    Name = "${var.name_prefix}-web-https"
  })
}

resource "aws_vpc_security_group_egress_rule" "all_ipv4" {
  security_group_id = aws_security_group.web.id
  description       = "Allow all egress traffic (IPv4)"
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"

  tags = merge(var.tags, {
    Name = "${var.name_prefix}-web-egress"
  })
}
