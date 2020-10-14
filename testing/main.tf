
locals {
    global = {
        vpn = {
            port                      = 443
            organization              = "QuayChain"
            certificate_key_algorithm = "RSA"
            certificate_key_bits      = 2048
            client_certificates = {
                kyle_kotowick_desktop = {},
                kyle_kotowick_laptop  = {},
                evan_petredis         = {},
                michael_stegeman      = {},
                prototype_01          = {},
                prototype_02          = {}
            }
            client_certificates_output_directory = "test/vpn_clients"
            config_template_file                 = "module/openvpn_client.template"
        }
    }
    config_dev = {
        vpn = {
            cidr_block = "10.202.0.0/16"
        }
        vpc = {
            cidr_block = "10.201.0.0/16",
            nat_gateway_azs = [0]
        }
        s3_force_destroy = true
        nucs = [
            "prototype_01"
        ]
    }
}
/*
module "deepmerge" {
    source = "../deepmerge"
    maps = [
        local.global,
        local.config_dev
    
    ]
}
/**/
/*
        {
            key2-1 = "value2-1"
            key2-2 = "value2-2"
            key2-3 = {
                key2-3-1 = "value2-3-1"
            }
            key1-3 = {
                key1-3-1 = {
                    key1-3-1-1 = "value1-3-1-1(b)"
                }
                key1-3-2 = {
                    key1-3-2-1 = {
                        key1-3-2-1-1 = "value1-3-2-1-1"
                        key1-3-2-1-2 = "value1-3-2-1-2"
                    }
                    key1-3-2-2 = {
                        key1-3-2-2-1 = "value1-3-2-2-1"
                        key1-3-2-2-2 = {
                            key1-3-2-2-2-1 = "value1-3-2-2-2-1"
                        }
                    }
                }
            }
            key1-1 = "value1-1(b)"
            key2-4 = 24
            key1-4 = 214
        },
        {
            key1-1 = "value1-1(a)"
            key1-2 = "value1-2"
            key1-3 = {
                key1-3-1 = {
                    key1-3-1-1 = {
                        key1-3-1-1-1 = "value1-3-1-1-1"
                    }
                    key1-3-1-2 = "value1-3-1-2"
                }
                key1-3-2 = "value1-3-2"
            }
            key1-4 = 14
        }
       */ 

output "deepmerge" {
    value = module.deepmerge
}
/**/
/* Expected
{
    key1-1 = "value1-1(b)"
    key1-2 = "value1-2"
    key1-3 = {
        key1-3-1 = {
            key1-3-1-1 = "value1-3-1-1(b)"
            key1-3-1-2 = "value1-3-1-2"
        }
        key1-3-2 = "value1-3-2"
    }
    key2-1 = "value2-1"
    key2-2 = "value2-2"
    key2-3 = {
        key2-3-1 = "value2-3-1"
    }
}
*/

resource "local_file" "foo" {
    content     = templatefile("${path.module}/../deepmerge/depth.tmpl", {max_depth = 100})
    filename = "${path.module}/../deepmerge/depth.tf"
}
/**/