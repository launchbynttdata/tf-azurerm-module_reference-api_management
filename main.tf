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

module "resource_group" {
  source  = "terraform.registry.launch.nttdata.com/module_primitive/resource_group/azurerm"
  version = "~> 1.0"

  count = var.resource_group_name != null ? 0 : 1

  location = var.region
  name     = local.resource_group_name

  tags = merge(local.tags, { resource_name = local.resource_group_name })
}

module "public_ip" {
  source  = "terraform.registry.launch.nttdata.com/module_primitive/public_ip/azurerm"
  version = "~> 1.0"

  count = local.create_ip_address ? 1 : 0

  name                = local.public_ip_name
  resource_group_name = var.resource_group_name != null ? var.resource_group_name : module.resource_group[0].name
  location            = var.region
  allocation_method   = "Static"
  domain_name_label   = local.public_ip_name
  sku                 = "Standard"
  sku_tier            = "Regional"

  tags = merge(local.tags, {
    resource_name = local.public_ip_name
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
      name                = local.apim_name
      records             = module.apim.api_management_private_ip_addresses
    }
    "portal" = {
      zone_name           = module.apim_default_dns_zone[0].zone_name
      resource_group_name = var.resource_group_name != null ? var.resource_group_name : module.resource_group[0].name
      ttl                 = var.default_ttl
      name                = "${local.apim_name}.portal"
      records             = module.apim.api_management_private_ip_addresses
    }
    "developer" = {
      zone_name           = module.apim_default_dns_zone[0].zone_name
      resource_group_name = var.resource_group_name != null ? var.resource_group_name : module.resource_group[0].name
      ttl                 = var.default_ttl
      name                = "${local.apim_name}.developer"
      records             = module.apim.api_management_private_ip_addresses
    }
    "management" = {
      zone_name           = module.apim_default_dns_zone[0].zone_name
      resource_group_name = var.resource_group_name != null ? var.resource_group_name : module.resource_group[0].name
      ttl                 = var.default_ttl
      name                = "${local.apim_name}.management"
      records             = module.apim.api_management_private_ip_addresses
    }
    "scm" = {
      zone_name           = module.apim_default_dns_zone[0].zone_name
      resource_group_name = var.resource_group_name != null ? var.resource_group_name : module.resource_group[0].name
      ttl                 = var.default_ttl
      name                = "${local.apim_name}.scm"
      records             = module.apim.api_management_private_ip_addresses
    }
  }

  depends_on = [module.apim_default_dns_zone, module.resource_group, module.apim]
}

module "nsg" {
  source  = "terraform.registry.launch.nttdata.com/module_primitive/network_security_group/azurerm"
  version = "~> 1.0"

  count = length(var.virtual_network_configuration) > 0 ? 1 : 0

  name                = local.nsg_name
  location            = var.region
  resource_group_name = var.resource_group_name != null ? var.resource_group_name : module.resource_group[0].name

  security_rules = local.all_nsg_rules

  tags = merge(local.tags, {
    resource_name = local.nsg_name
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

  name                = local.apim_name
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

module "key_vault_role_assignments" {
  source  = "terraform.registry.launch.nttdata.com/module_primitive/role_assignment/azurerm"
  version = "~> 1.0"

  for_each = var.key_vaults

  scope                = each.value
  role_definition_name = "Key Vault Secrets User"
  principal_id         = module.apim.api_management_identity[0].principal_id

  depends_on = [module.apim]
}

module "apim_certificates" {
  source  = "terraform.registry.launch.nttdata.com/module_primitive/api_management_certificate/azurerm"
  version = "~> 1.0"

  for_each = var.certificates

  resource_group_name = var.resource_group_name != null ? var.resource_group_name : module.resource_group[0].name
  api_management_name = module.apim.api_management_name

  name                         = each.key
  data                         = each.value.data
  password                     = each.value.password
  key_vault_secret_id          = each.value.key_vault_secret_id
  key_vault_identity_client_id = each.value.key_vault_identity_client_id

  depends_on = [module.apim, module.key_vault_role_assignments]
}

module "apim_loggers" {
  source  = "terraform.registry.launch.nttdata.com/module_primitive/api_management_logger/azurerm"
  version = "~> 1.0"

  for_each = var.loggers

  resource_group_name = var.resource_group_name != null ? var.resource_group_name : module.resource_group[0].name
  api_management_name = module.apim.api_management_name

  name        = each.key
  buffered    = each.value.buffered
  description = each.value.description

  application_insights = each.value.application_insights
  eventhub             = each.value.eventhub

  depends_on = [module.apim]
}

module "apim_named_values" {
  source  = "terraform.registry.launch.nttdata.com/module_primitive/api_management_named_value/azurerm"
  version = "~> 1.0"

  for_each = var.named_values

  resource_group_name = var.resource_group_name != null ? var.resource_group_name : module.resource_group[0].name
  api_management_name = module.apim.api_management_name

  name                 = each.key
  display_name         = coalesce(each.value.display_name, each.key)
  value                = each.value.value
  secret               = each.value.secret
  value_from_key_vault = each.value.value_from_key_vault

  depends_on = [module.apim, module.key_vault_role_assignments]
}

module "apim_backends" {
  source  = "terraform.registry.launch.nttdata.com/module_primitive/api_management_backend/azurerm"
  version = "~> 1.0"

  for_each = var.backends

  resource_group_name = var.resource_group_name != null ? var.resource_group_name : module.resource_group[0].name
  api_management_name = module.apim.api_management_name

  name        = each.key
  title       = each.value.title
  description = each.value.description
  url         = each.value.url
  protocol    = each.value.protocol

  credentials = each.value.credentials != null ? {
    authorization = each.value.credentials.authorization
    certificate = each.value.credentials.certificate != null ? [
      // Users of this module define certificates by name, here we map those names to the thumbprints
      for cert in each.value.credentials.certificate : module.apim_certificates[cert].certificate_thumbprint
    ] : null
    header = each.value.credentials.header
    query  = each.value.credentials.query
  } : null
  proxy                  = each.value.proxy
  resource_id            = each.value.resource_id
  service_fabric_cluster = each.value.service_fabric_cluster
  tls                    = each.value.tls

  depends_on = [module.apim, module.apim_certificates]
}


module "apim_apis" {
  source  = "terraform.registry.launch.nttdata.com/module_primitive/api_management_api/azurerm"
  version = "~> 1.0"

  for_each = var.apis

  resource_group_name = var.resource_group_name != null ? var.resource_group_name : module.resource_group[0].name
  api_management_name = module.apim.api_management_name

  name         = each.key
  display_name = each.value.display_name
  description  = each.value.description
  path         = each.value.path
  protocols    = each.value.protocols
  api_type     = each.value.api_type

  service_url           = each.value.service_url
  soap_pass_through     = each.value.soap_pass_through
  subscription_required = each.value.subscription_required

  import = each.value.import
  policy = each.value.policy

  contact              = each.value.contact
  license              = each.value.license
  terms_of_service_url = each.value.terms_of_service_url

  # module does not support multiple revisions at this time
  # terraform would destroy the previous revision if changed
  revision = "1"

  depends_on = [module.apim, module.apim_backends, module.apim_named_values]
}

module "apim_diagnostics" {
  source  = "terraform.registry.launch.nttdata.com/module_primitive/api_management_diagnostic/azurerm"
  version = "~> 1.0"

  for_each = var.diagnostics

  resource_group_name = var.resource_group_name != null ? var.resource_group_name : module.resource_group[0].name
  api_management_name = module.apim.api_management_name
  logger_name         = each.value.logger_name
  api_name            = each.value.api_name
  identifier          = each.value.identifier

  always_log_errors         = each.value.always_log_errors
  http_correlation_protocol = each.value.http_correlation_protocol
  operation_name_format     = each.value.operation_name_format
  log_client_ip             = each.value.log_client_ip
  sampling_percentage       = each.value.sampling_percentage
  verbosity                 = each.value.verbosity

  frontend_request  = each.value.frontend_request
  frontend_response = each.value.frontend_response
  backend_request   = each.value.backend_request
  backend_response  = each.value.backend_response

  depends_on = [module.apim_apis, module.apim_loggers]
}
