variable "name" {}

variable "virtual_wan_id" {}

variable "rg" {
  type = object({
    name     = string
    location = string
  })
}

variable "address_prefix" {}

variable "firewall" {
  type = object({
    firewall_policy_id = string
    sku_name           = optional(string, "AZFW_VNet")
    sku_tier           = optional(string, "Basic")
  })
  default = null
}

variable "connections" {
  type    = map(string)
  default = {}
  nullable = false
}

variable "vpn_server_configurations" {
  type = map(object({
    authentication_types     = set(string)
    vpn_protocols            = set(string)
    client_root_certificates = optional(map(string), {})
    aad_authentication = optional(object({
      audience = string
      issuer   = string
      tenant   = string
    }))
    policy_groups = optional(map(object({
      policies = list(object({
        name  = string
        type  = string
        value = string
      }))
    })))
  }))
  default = {}
  nullable = false
}

variable "point_to_site_vpn_gateways" {
  type = map(object({
    vpn_server_configuration = string
    scale_unit               = optional(number, 1)
    address_prefixes         = set(string)
  }))
  default = {}
  nullable = false
}