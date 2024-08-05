###
# Resources
###
resource "azurerm_dns_a_record" "stacks_app" {
  name                = var.dns_a_record_name
  zone_name           = data.azurerm_dns_zone.default.name
  resource_group_name = data.azurerm_dns_zone.default.resource_group_name
  ttl                 = var.dns_a_record_ttl
  target_resource_id  = data.azurerm_public_ip.application_gateway.id
}
