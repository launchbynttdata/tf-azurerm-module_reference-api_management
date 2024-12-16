// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

module "resource_names" {
  source  = "terraform.registry.launch.nttdata.com/module_library/resource_name/launch"
  version = "~> 1.0"

  for_each = var.resource_names_map

  logical_product_family  = var.product_family
  logical_product_service = var.product_service
  region                  = join("", split("-", var.region))
  class_env               = var.environment
  cloud_resource_type     = each.value.name
  instance_env            = var.environment_number
  instance_resource       = var.resource_number
  maximum_length          = each.value.max_length
  use_azure_region_abbr   = true

}

module "resource_names_v2" {
  source  = "terraform.registry.launch.nttdata.com/module_library/resource_name/launch"
  version = "~> 2.0"

  for_each = local.use_v2_resource_names ? var.resource_names_map : {}

  region                  = join("", split("-", var.location))
  class_env               = var.environment
  cloud_resource_type     = each.value.name
  instance_env            = var.resource_number
  maximum_length          = each.value.max_length
  logical_product_family  = var.product_family
  logical_product_service = var.product_service
  use_azure_region_abbr   = true
}

module "resource_group" {
  source  = "terraform.registry.launch.nttdata.com/module_primitive/resource_group/azurerm"
  version = "~> 1.0"

  count = var.resource_group_name != null ? 0 : 1

  location = var.region
  name     = module.resource_names["resource_group"].standard

  tags = merge(local.tags, { resource_name = module.resource_names["resource_group"].standard })
}

module "public_ip" {
  source  = "terraform.registry.launch.nttdata.com/module_primitive/public_ip/azurerm"
  version = "~> 1.0"

  count = local.create_ip_address ? 1 : 0

  name                = module.resource_names["public_ip"].standard
  resource_group_name = var.resource_group_name != null ? var.resource_group_name : module.resource_group[0].name
  location            = var.region
  allocation_method   = "Static"
  domain_name_label   = module.resource_names["public_ip"].standard
  sku                 = "Standard"
  sku_tier            = "Regional"

  tags = merge(local.tags, {
    resource_name = module.resource_names["public_ip"].standard
  })

  depends_on = [module.resource_group]
}

module "apim_default_dns_zone" {
  source  = "terraform.registry.launch.nttdata.com/module_primitive/private_dns_zone/azurerm"
  version = "~> 1.0"

  count = var.virtual_network_type == "Internal" ? 1 : 0

  zone_name           = var.dns_zone_suffix
  resource_group_name = var.resource_group_name != null ? var.resource_group_name : module.resource_group[0].name

  tags = local.tags

  depends_on = [module.resource_group]
}

module "vnet_links" {
  source  = "terraform.registry.launch.nttdata.com/module_primitive/private_dns_vnet_link/azurerm"
  version = "~> 1.0"

  for_each = var.virtual_network_type == "Internal" ? local.all_vnet_links : {}

  link_name             = each.key
  resource_group_name   = var.resource_group_name != null ? var.resource_group_name : module.resource_group[0].name
  private_dns_zone_name = module.apim_default_dns_zone[0].zone_name
  virtual_network_id    = each.value
  registration_enabled  = false

  tags = local.tags

  depends_on = [module.apim_default_dns_zone, module.resource_group]
}

module "dns_records" {
  source  = "terraform.registry.launch.nttdata.com/module_primitive/private_dns_records/azurerm"
  version = "~> 1.0"
  count   = var.virtual_network_type == "Internal" ? 1 : 0
  a_records = {
    "apim" = {
      zone_name           = module.apim_default_dns_zone[0].zone_name
      resource_group_name = var.resource_group_name != null ? var.resource_group_name : module.resource_group[0].name
      ttl                 = var.default_ttl
      name                = module.resource_names["apim"].standard
      records             = module.apim.api_management_private_ip_addresses
    }
    "portal" = {
      zone_name           = module.apim_default_dns_zone[0].zone_name
      resource_group_name = var.resource_group_name != null ? var.resource_group_name : module.resource_group[0].name
      ttl                 = var.default_ttl
      name                = "${module.resource_names["apim"].standard}.portal"
      records             = module.apim.api_management_private_ip_addresses
    }
    "developer" = {
      zone_name           = module.apim_default_dns_zone[0].zone_name
      resource_group_name = var.resource_group_name != null ? var.resource_group_name : module.resource_group[0].name
      ttl                 = var.default_ttl
      name                = "${module.resource_names["apim"].standard}.developer"
      records             = module.apim.api_management_private_ip_addresses
    }
    "management" = {
      zone_name           = module.apim_default_dns_zone[0].zone_name
      resource_group_name = var.resource_group_name != null ? var.resource_group_name : module.resource_group[0].name
      ttl                 = var.default_ttl
      name                = "${module.resource_names["apim"].standard}.management"
      records             = module.apim.api_management_private_ip_addresses
    }
    "scm" = {
      zone_name           = module.apim_default_dns_zone[0].zone_name
      resource_group_name = var.resource_group_name != null ? var.resource_group_name : module.resource_group[0].name
      ttl                 = var.default_ttl
      name                = "${module.resource_names["apim"].standard}.scm"
      records             = module.apim.api_management_private_ip_addresses
    }
  }

  depends_on = [module.apim_default_dns_zone, module.resource_group, module.apim]
}

module "nsg" {
  source  = "terraform.registry.launch.nttdata.com/module_primitive/network_security_group/azurerm"
  version = "~> 1.0"

  count = length(var.virtual_network_configuration) > 0 ? 1 : 0

  name                = module.resource_names["nsg"].standard
  location            = var.region
  resource_group_name = var.resource_group_name != null ? var.resource_group_name : module.resource_group[0].name

  security_rules = local.all_nsg_rules

  tags = merge(local.tags, {
    resource_name = module.resource_names["nsg"].standard
  })

  depends_on = [module.resource_group]
}

module "nsg_subnet_assoc" {
  source  = "terraform.registry.launch.nttdata.com/module_primitive/nsg_subnet_association/azurerm"
  version = "~> 1.0"

  count = length(var.virtual_network_configuration) > 0 ? 1 : 0

  subnet_id                 = var.virtual_network_configuration[0]
  network_security_group_id = module.nsg[0].network_security_group_id

  depends_on = [module.nsg]
}


module "apim" {
  source  = "terraform.registry.launch.nttdata.com/module_primitive/api_management/azurerm"
  version = "~> 1.0"

  name                = module.resource_names["apim"].standard
  location            = var.region
  resource_group_name = var.resource_group_name != null ? var.resource_group_name : module.resource_group[0].name

  publisher_name  = var.publisher_name
  publisher_email = var.publisher_email
  sku_name        = var.sku_name
  zones           = var.zones

  public_network_access_enabled = var.public_network_access_enabled
  public_ip_address_id          = length(module.public_ip) > 0 ? module.public_ip[0].id : null

  additional_location = var.additional_location

  certificate_configuration = var.certificate_configuration

  client_certificate_enabled = var.client_certificate_enabled
  gateway_disabled           = var.gateway_disabled
  min_api_version            = var.min_api_version

  identity_type = var.identity_type
  identity_ids  = var.identity_ids

  management_hostname_configuration       = var.management_hostname_configuration
  portal_hostname_configuration           = var.portal_hostname_configuration
  developer_portal_hostname_configuration = var.developer_portal_hostname_configuration
  proxy_hostname_configuration            = var.proxy_hostname_configuration

  scm_hostname_configuration = var.scm_hostname_configuration
  policy_configuration       = var.policy_configuration


  notification_sender_email = var.notification_sender_email

  enable_http2 = var.enable_http2

  security_configuration = var.security_configuration

  enable_sign_in = var.enable_sign_in
  enable_sign_up = var.enable_sign_up


  terms_of_service_configuration = var.terms_of_service_configuration
  virtual_network_configuration  = var.virtual_network_configuration

  virtual_network_type = var.virtual_network_type

  tags = local.tags

  depends_on = [module.resource_group, module.public_ip]
}
