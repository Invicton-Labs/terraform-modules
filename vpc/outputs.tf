output "public_subnets" {
  description = "All public subnets that have been provisioned (a map of AZ name keys with resource values)."
  value       = aws_subnet.public
}
output "private_subnets" {
  description = "All private subnets that have been provisioned (a map of AZ name keys with resource values)."
  value       = aws_subnet.private
}
output "provisioned_azs" {
  description = "A list of all AZ names that subnets have been provisioned for."
  value       = local.azs
}
output "vpc" {
  description = "The VPC resource."
  value       = aws_vpc.vpc
}
output "nat_azs" {
  value = local.nat_azs
}
