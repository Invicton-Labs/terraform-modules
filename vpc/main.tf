// Create the VPC
resource "aws_vpc" "vpc" {
  cidr_block                       = var.cidr_block
  instance_tenancy                 = var.instance_tenancy
  enable_dns_support               = var.enable_dns_support
  enable_dns_hostnames             = var.enable_dns_hostnames
  enable_classiclink_dns_support   = var.enable_classiclink_dns_support
  assign_generated_ipv6_cidr_block = var.assign_generated_ipv6_cidr_block
  tags                             = var.tags
}

// Get the current region
data "aws_region" "current" {}

// Get a list of all availability zones in the region
data "aws_availability_zones" "all" {}

locals {
  // Allocate 2 subnets for each AZ: private and public
  num_subnets     = var.max_azs * 2
  bits_per_subnet = ceil(log(local.num_subnets, 2))
  subnet_cidrs    = cidrsubnets(var.cidr_block, [for i in range(local.num_subnets) : local.bits_per_subnet]...)
  all_azs         = sort(data.aws_availability_zones.all.names)
  // Determine which AZs to provision. Will provision subnets in each one unless there are more subnets than the upper defined limit. Sort alphabetically for consistency.
  azs = length(local.all_azs) > var.max_azs ? slice(local.all_azs, 0, var.max_azs) : sort(local.all_azs)
  az_map = {
    for i in range(length(local.azs)) :
    local.azs[i] => { "private" : local.subnet_cidrs[i * 2], "public" : local.subnet_cidrs[i * 2 + 1] }
  }
  nat_azs = distinct([for i in var.nat_gateway_azs : local.azs[i]])
}

// Provision all private subnets
resource "aws_subnet" "private" {
  for_each          = local.az_map
  vpc_id            = aws_vpc.vpc.id
  availability_zone = each.key
  cidr_block        = each.value.private
  tags = {
    Name = "${each.key} (Private)"
  }
  lifecycle {
    create_before_destroy = true
  }
}

// Provision all public subnets
resource "aws_subnet" "public" {
  for_each          = local.az_map
  vpc_id            = aws_vpc.vpc.id
  availability_zone = each.key
  cidr_block        = each.value.public
  tags = {
    Name = "${each.key} (Public)"
  }
}

// Provision the Internet Gateway
resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.vpc.id
  tags = {
    Name = "Internet Gateway"
  }
}

// Create a route table for the public subnets to use
resource "aws_route_table" "public-egress" {
  vpc_id = aws_vpc.vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }
  tags = {
    Name = "Direct public egress"
  }
}

// Associate the primary public subnets with the public route table
resource "aws_route_table_association" "public" {
  for_each       = aws_subnet.public
  subnet_id      = each.value.id
  route_table_id = aws_route_table.public-egress.id
}

// Allocate an elastic IP for assigning to the NAT Gateway
resource "aws_eip" "nat" {
  for_each = toset(local.nat_azs)
  vpc      = true
}

// Create the NAT Gateways
resource "aws_nat_gateway" "gw" {
  for_each      = aws_eip.nat
  allocation_id = aws_eip.nat[each.key].id
  subnet_id     = aws_subnet.public[each.key].id
}

// Create a route table that allows egress through the NAT gateway
resource "aws_route_table" "private" {
  for_each = aws_nat_gateway.gw
  vpc_id   = aws_vpc.vpc.id
  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = each.value.id
  }
  tags = {
    Name = "Public egress via ${each.key} NAT Gateway"
  }
}

// Associate the primary private subnets with the private route table
resource "aws_route_table_association" "private" {
  // Only do this at all if there is at least one NAT Gateway provisioned
  for_each  = length(local.nat_azs) > 0 ? aws_subnet.private : {}
  subnet_id = each.value.id
  // If there's a NAT Gateway in the given AZ, use it. Otherwise, use the default AZ's gateway.
  route_table_id = lookup(aws_route_table.private, each.key, aws_route_table.private[keys(aws_route_table.private)[var.default_nat_gateway_az]])["id"]
}
