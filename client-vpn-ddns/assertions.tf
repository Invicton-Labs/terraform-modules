// Ensure that DNS and hostnames are enabled in the VPC
module "assert_vpc_dns" {
  source        = "../assert"
  condition     = data.aws_vpc.vpc.enable_dns_support
  error_message = "The given VPC does not have DNS support enabled. It is required for VPN DDNS."
}
module "assert_vpc_hostnames" {
  source        = "../assert"
  condition     = data.aws_vpc.vpc.enable_dns_hostnames
  error_message = "The given VPC does not have DNS hostnames support enabled. It is required for VPN DDNS."
}

// Ensure that the VPC is using AmazonProvidedDNS
module "assert_amazon_provided_dns" {
  source        = "../assert"
  condition     = length(data.aws_vpc_dhcp_options.vpc_dhcp_options.domain_name_servers) == 1 && data.aws_vpc_dhcp_options.vpc_dhcp_options.domain_name_servers[0] == "AmazonProvidedDNS"
  error_message = "The given VPC (${var.vpc_id}) is not using AmazonProvidedDNS (possibly using custom DNS servers). The 'client-vpn-ddns' module only supports VPCs that use AmazonProvidedDNS."
}
