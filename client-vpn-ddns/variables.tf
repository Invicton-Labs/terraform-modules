variable "vpc_id" {
  description = "The ID of the VPC to create this DDNS for."
  type        = string
}
variable "client_vpn_endpoint_id" {
  description = "The ID of the Client VPN Endpoint."
  type        = string
}
variable "private_hosted_zone_name" {
  description = "The name of the new private hosted zone to create."
  type        = string
}
variable "private_hosted_zone_force_destroy" {
  description = "Whether the new private Route53 hosted zone should be force-destroyed when the resource shoudl be destroyed. Defaults `false`."
  type        = bool
  default     = false
}
