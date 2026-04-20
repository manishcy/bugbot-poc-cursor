resource "aws_security_group" "web" {
  name        = "${var.name}-web-sg"
  description = "Allow inbound HTTP/HTTPS to web tier and all egress"
  vpc_id      = aws_vpc.this.id

  tags = merge(local.common_tags, {
    Name = "${var.name}-web-sg"
  })

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_vpc_security_group_ingress_rule" "web_http" {
  for_each = toset(var.web_ingress_cidrs)

  security_group_id = aws_security_group.web.id
  description       = "Allow HTTP from ${each.value}"
  cidr_ipv4         = each.value
  from_port         = 80
  to_port           = 80
  ip_protocol       = "tcp"

  tags = merge(local.common_tags, {
    Name = "${var.name}-web-http"
  })
}

resource "aws_vpc_security_group_ingress_rule" "web_https" {
  for_each = toset(var.web_ingress_cidrs)

  security_group_id = aws_security_group.web.id
  description       = "Allow HTTPS from ${each.value}"
  cidr_ipv4         = each.value
  from_port         = 443
  to_port           = 443
  ip_protocol       = "tcp"

  tags = merge(local.common_tags, {
    Name = "${var.name}-web-https"
  })
}

resource "aws_vpc_security_group_egress_rule" "web_all_ipv4" {
  security_group_id = aws_security_group.web.id
  description       = "Allow all egress IPv4"
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"

  tags = merge(local.common_tags, {
    Name = "${var.name}-web-egress-ipv4"
  })
}
