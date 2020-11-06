variable "cidr_block" {
  description = "The CIDR block for the VPN IP addresses."
  type        = string
}
variable "instance_tenancy" {
  description = "A tenancy option for instances launched into the VPC. Options are 'default', 'dedicated', or 'host'."
  type        = string
  default     = "default"
}
variable "enable_dns_support" {
  description = "A boolean flag to enable/disable DNS support in the VPC. Defaults true."
  type        = bool
  default     = true
}
variable "enable_dns_hostnames" {
  description = "A boolean flag to enable/disable DNS hostnames in the VPC. Defaults false."
  type        = bool
  default     = false
}
variable "enable_classiclink" {
  description = "A boolean flag to enable/disable ClassicLink for the VPC. Only valid in regions and accounts that support EC2 Classic. Defaults false."
  type        = bool
  default     = false
}
variable "enable_classiclink_dns_support" {
  description = "A boolean flag to enable/disable ClassicLink DNS Support for the VPC. Only valid in regions and accounts that support EC2 Classic. Defaults false."
  type        = bool
  default     = false
}
variable "assign_generated_ipv6_cidr_block" {
  description = "Requests an Amazon-provided IPv6 CIDR block with a /56 prefix length for the VPC. You cannot specify the range of IP addresses, or the size of the CIDR block. Defaults false."
  type        = bool
  default     = false
}
variable "tags" {
  description = "A map of tags to assign to the resource."
  type        = map(string)
  default     = {}
}
variable "max_azs" {
  description = "The maximum number of AZs to split the CIDR block across. Defaults to 12. At the time of writing, the largest AWS region has 6 AZs, but this allows that number to grow without having to re-split the block."
  type        = number
  default     = 12
}
variable "nat_gateway_azs" {
  description = "A list of AZ indecies that should have NAT gateways for their private subnets. Note that these are numerical indecies if AZs that are available on your account. e.g. if the region is 'us-east-1' and the available AZs are ['us-east-1a', 'us-east-1b', 'us-east-1d'], then a value for this variable of [0,2] would provision NAT gateways in 'use-east-1a' and 'us-east-1d'. Defaults to an empty list ([]), i.e. no provisioned NAT gateways."
  type        = list(number)
  default     = []
}
variable "default_nat_gateway_az" {
  description = "The numerical ID of the AZ that has a NAT Gateway and that public internet requests from AZs that don't have their own NAT Gateway should be routed through. This value must also be present in the 'nat_gateway_azs' variable. Defaults to 0 (will have no effect if no 'nat_gateway_azs' list was provided)."
  type        = number
  default     = 0
}
