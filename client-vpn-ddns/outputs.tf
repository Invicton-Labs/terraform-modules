output "vpc_dhcp_options" {
  value = data.aws_vpc_dhcp_options.vpc_dhcp_options
}

output "vpc" {
  value = data.aws_vpc.vpc
}

output "vpc_dns_ip" {
  value = local.vpc_aws_dns_ip
}
