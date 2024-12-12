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

locals {

  # Fetching the Vnet ID from input subnet ID
  # Required only when virtual_network_type = External or Internal
  vnet_id = length(var.virtual_network_configuration) > 0 ? join("/", slice(split("/", var.virtual_network_configuration[0]), 0, 9)) : null

  apim_vnet_link = length(var.virtual_network_configuration) > 0 ? {
    private-apim-vnet-link = local.vnet_id
  } : {}

  all_vnet_links = merge(local.apim_vnet_link, var.additional_vnet_links)

  create_ip_address = (
    (startswith(var.sku_name, "Developer") || startswith(var.sku_name, "Premium"))
    && contains(["External", "Internal"], var.virtual_network_type)
    && length(var.virtual_network_configuration) > 0
  )

  default_apim_nsg_rules = [
    {
      name                       = "management-endpoint"
      description                = "Management endpoint for Azure portal and PowerShell"
      protocol                   = "Tcp"
      source_port_range          = "*"
      destination_port_range     = 3443
      source_address_prefix      = "ApiManagement"
      destination_address_prefix = "VirtualNetwork"
      access                     = "Allow"
      priority                   = 100
      direction                  = "Inbound"
    },
    {
      name                       = "load-balancer"
      description                = "Azure Infrastructure Load Balancer"
      protocol                   = "Tcp"
      source_port_range          = "*"
      destination_port_range     = 6390
      source_address_prefix      = "AzureLoadBalancer"
      destination_address_prefix = "VirtualNetwork"
      access                     = "Allow"
      priority                   = 101
      direction                  = "Inbound"
    },
    {
      name                       = "azure-storage"
      description                = "Dependency on Azure Storage for core service functionality"
      protocol                   = "Tcp"
      source_port_range          = "*"
      destination_port_range     = 443
      source_address_prefix      = "VirtualNetwork"
      destination_address_prefix = "Storage"
      access                     = "Allow"
      priority                   = 102
      direction                  = "Outbound"
    },
    {
      name                       = "azure-sql"
      description                = "Access to Azure SQL endpoints for core service functionality"
      protocol                   = "Tcp"
      source_port_range          = "*"
      destination_port_range     = 1443
      source_address_prefix      = "VirtualNetwork"
      destination_address_prefix = "SQL"
      access                     = "Allow"
      priority                   = 103
      direction                  = "Outbound"
    },
    {
      name                       = "azure-key-vault"
      description                = "Access to Azure Key Vault for core service functionality"
      protocol                   = "Tcp"
      source_port_range          = "*"
      destination_port_range     = 443
      source_address_prefix      = "VirtualNetwork"
      destination_address_prefix = "AzureKeyVault"
      access                     = "Allow"
      priority                   = 104
      direction                  = "Outbound"
    },
    {
      name                       = "azure-monitor"
      description                = "Publish Diagnostics Logs and Metrics, Resource Health, and Application Insights"
      protocol                   = "Tcp"
      source_port_range          = "*"
      destination_port_ranges    = [1886, 443]
      source_address_prefix      = "VirtualNetwork"
      destination_address_prefix = "AzureMonitor"
      access                     = "Allow"
      priority                   = 105
      direction                  = "Outbound"
    }
  ]

  all_nsg_rules = concat(local.default_apim_nsg_rules, var.additional_nsg_rules)

  default_tags = {
    provisioner = "Terraform"
  }

  tags = merge(local.default_tags, var.tags)
}
