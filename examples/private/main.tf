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
  region                  = var.region
  class_env               = var.environment
  cloud_resource_type     = each.value.name
  instance_env            = var.environment_number
  maximum_length          = each.value.max_length
  use_azure_region_abbr   = true
}

module "resource_group" {
  source  = "terraform.registry.launch.nttdata.com/module_primitive/resource_group/azurerm"
  version = "~> 1.0"

  name     = module.resource_names["resource_group"].minimal_random_suffix
  location = var.region

  tags = merge(var.tags, { resource_name = module.resource_names["resource_group"].standard })

}

module "virtual_network" {
  source  = "terraform.registry.launch.nttdata.com/module_primitive/virtual_network/azurerm"
  version = "~> 3.0"

  resource_group_name = module.resource_group.name
  vnet_name           = module.resource_names["virtual_network"].minimal_random_suffix
  vnet_location       = var.region

  address_space = [var.address_prefix]

  subnets = {
    "api-management-subnet" = {
      prefix = var.address_prefix
    }
  }

  tags = merge(var.tags, { resource_name = module.resource_names["virtual_network"].standard })

  depends_on = [
    module.resource_group,
  ]
}

module "apim" {
  source = "../.."

  product_family     = var.product_family
  product_service    = var.product_service
  environment        = var.environment
  environment_number = var.environment_number
  resource_number    = var.resource_number
  region             = var.region

  sku_name        = var.sku_name
  publisher_name  = var.publisher_name
  publisher_email = var.publisher_email

  public_network_access_enabled = var.public_network_access_enabled

  virtual_network_type = var.virtual_network_type
  virtual_network_configuration = [
    module.virtual_network.subnet_name_id_map["api-management-subnet"]
  ]

  tags = var.tags
}
