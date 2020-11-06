resource "aws_route53_zone" "private" {
  name          = var.private_hosted_zone_name
  force_destroy = var.private_hosted_zone_force_destroy
  vpc {
    vpc_id = data.aws_vpc.vpc.id
  }
}

data "aws_vpc" "vpc" {
  id = var.vpc_id
}

locals {
  // AWS default DNS (AmazonProvidedDNS) uses an IP address that is always the base IPv4 CIDR plus 2 (https://docs.aws.amazon.com/vpc/latest/userguide/VPC_DHCP_Options.html#AmazonDNS)
  vpc_aws_dns_ip = cidrhost(data.aws_vpc.vpc.cidr_block, 2)
}

data "aws_vpc_dhcp_options" "vpc_dhcp_options" {
  dhcp_options_id = data.aws_vpc.vpc.dhcp_options_id
}

// Authorize ingress from VPN clients to the DNS server
resource "aws_ec2_client_vpn_authorization_rule" "dns" {
  client_vpn_endpoint_id = var.client_vpn_endpoint_id
  target_network_cidr    = "${local.vpc_aws_dns_ip}/32"
  authorize_all_groups   = true
}

// Create a policy document that allows the Lambda to get connected clients and to update Route53 records
data "aws_iam_policy_document" "ddns" {
  // Allow describing VPN connections
  statement {
    actions = [
      "ec2:DescribeClientVpnConnections"
    ]
    resources = [
      "*"
    ]
  }
  // Allow updating the Route53 zone
  statement {
    actions = [
      "route53:ChangeResourceRecordSets",
      "route53:ListResourceRecordSets",
    ]
    resources = [
      "arn:aws:route53:::hostedzone/${aws_route53_zone.private.zone_id}"
    ]
  }
}
resource "aws_iam_policy" "ddns" {
  name_prefix = "ClientVPN-DDNS-${var.client_vpn_endpoint_id}-"
  path        = "/client-vpn-ddns/"
  policy      = data.aws_iam_policy_document.ddns.json
}

// Create the Lambda function for triggering on an uploaded image
module "lambda_ddns" {
  source           = "../lambda-set"
  name             = "client-vpn-ddns-${var.client_vpn_endpoint_id}"
  edge             = false
  handler          = "main.lambda_handler"
  runtime          = "python3.8"
  memory_size      = 128
  timeout          = 5
  directory        = "${path.module}/ddns"
  role_policy_arns = [aws_iam_policy.ddns.arn]
  environment = {
    CLIENT_VPN_ENDPOINT_ID = var.client_vpn_endpoint_id
    HOSTED_ZONE_ID         = aws_route53_zone.private.zone_id
    HOSTED_ZONE_NAME       = var.private_hosted_zone_name
  }
  schedules = ["rate(1 minute)"]
}

output "vpc_dhcp_options" {
  value = data.aws_vpc_dhcp_options.vpc_dhcp_options
}

output "vpc" {
  value = data.aws_vpc.vpc
}

output "vpc_dns_ip" {
  value = local.vpc_aws_dns_ip
}
