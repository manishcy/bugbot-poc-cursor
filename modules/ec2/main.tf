locals {
  effective_security_group_ids = var.create_security_group ? concat(var.security_group_ids, [aws_security_group.this[0].id]) : var.security_group_ids
  instance_key_name            = var.create_key_pair ? aws_key_pair.this[0].key_name : var.key_name

  merged_instance_tags       = merge(var.tags, var.instance_tags, { Name = var.instance_name })
  merged_key_pair_tags       = merge(var.tags, var.key_pair_tags, { Name = coalesce(var.key_name, var.instance_name) })
  merged_security_group_tags = merge(var.tags, var.security_group_tags, { Name = var.security_group_name })
}

resource "aws_security_group" "this" {
  count = var.create_security_group ? 1 : 0

  name        = var.security_group_name
  description = var.security_group_description
  vpc_id      = var.vpc_id

  dynamic "ingress" {
    for_each = var.security_group_ingress_rules
    content {
      description      = ingress.value.description
      from_port        = ingress.value.from_port
      to_port          = ingress.value.to_port
      protocol         = ingress.value.protocol
      cidr_blocks      = ingress.value.cidr_blocks
      ipv6_cidr_blocks = ingress.value.ipv6_cidr_blocks
      prefix_list_ids  = ingress.value.prefix_list_ids
      security_groups  = ingress.value.security_groups
      self             = ingress.value.self
    }
  }

  dynamic "egress" {
    for_each = var.security_group_egress_rules
    content {
      description      = egress.value.description
      from_port        = egress.value.from_port
      to_port          = egress.value.to_port
      protocol         = egress.value.protocol
      cidr_blocks      = egress.value.cidr_blocks
      ipv6_cidr_blocks = egress.value.ipv6_cidr_blocks
      prefix_list_ids  = egress.value.prefix_list_ids
      security_groups  = egress.value.security_groups
      self             = egress.value.self
    }
  }

  tags = local.merged_security_group_tags
}

resource "aws_key_pair" "this" {
  count = var.create_key_pair ? 1 : 0

  key_name   = var.key_name
  public_key = var.public_key

  tags = local.merged_key_pair_tags
}

resource "aws_instance" "this" {
  ami           = var.ami_id
  instance_type = var.instance_type

  subnet_id                   = var.subnet_id
  availability_zone           = var.availability_zone
  associate_public_ip_address = var.associate_public_ip_address
  vpc_security_group_ids      = length(local.effective_security_group_ids) > 0 ? local.effective_security_group_ids : null
  key_name                    = local.instance_key_name
  user_data                   = var.user_data

  tags = local.merged_instance_tags
}
