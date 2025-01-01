resource "azurerm_virtual_hub" "this" {
  name                = var.name
  resource_group_name = var.rg.name
  location            = var.rg.location
  virtual_wan_id      = var.virtual_wan_id
  address_prefix      = var.address_prefix
}

resource "azurerm_firewall" "this" {
  count               = var.firewall == null ? 0 : 1
  name                = "${var.name}-firewall"
  resource_group_name = var.rg.name
  location            = var.rg.location
  sku_name            = var.firewall.sku_name
  sku_tier            = var.firewall.sku_tier
  firewall_policy_id  = var.firewall.firewall_policy_id

  virtual_hub {
    virtual_hub_id = azurerm_virtual_hub.this.id
  }
}

resource "azurerm_virtual_hub_connection" "this" {
  for_each                  = var.connections
  virtual_hub_id            = azurerm_virtual_hub.this.id
  name                      = each.key
  remote_virtual_network_id = each.value
}

module "vpn_server_configurations" {
  source                  = "app.terraform.io/ptonini-org/vpn-server-configuration/azurerm"
  for_each                = var.vpn_server_configurations
  name                    = each.key
  rg                      = var.rg
  virtual_wan_id          = var.virtual_wan_id
  authentication_types    = each.value.authentication_types
  vpn_protocols           = each.value.vpn_protocols
  client_root_certificate = each.value.client_root_certificates
  aad_authentication      = each.value.aad_authentication
  policy_groups           = each.value.policy_groups
}

resource "azurerm_point_to_site_vpn_gateway" "this" {
  for_each                    = var.point_to_site_vpn_gateways
  name                        = each.key
  resource_group_name         = var.rg.name
  location                    = var.rg.location
  virtual_hub_id              = azurerm_virtual_hub.this.id
  vpn_server_configuration_id = module.vpn_server_configurations[each.value.vpn_server_configuration].this.id
  scale_unit                  = each.value.scale_unit

  connection_configuration {
    name = each.key

    vpn_client_address_pool {
      address_prefixes = each.value.address_prefixes
    }
  }
}