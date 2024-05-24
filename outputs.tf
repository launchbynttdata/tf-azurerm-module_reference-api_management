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

output "api_management_name" {
  description = "The name of the API Management Service"
  value       = module.apim.api_management_name
}

output "api_management_id" {
  description = "The ID of the API Management Service"
  value       = module.apim.api_management_id
}

output "api_management_additional_location" {
  description = "Map listing gateway_regional_url and public_ip_addresses associated"
  value       = module.apim.api_management_additional_location
}

output "api_management_gateway_url" {
  description = "The URL of the Gateway for the API Management Service"
  value       = module.apim.api_management_gateway_url
}

output "api_management_gateway_regional_url" {
  description = "The Region URL for the Gateway of the API Management Service"
  value       = module.apim.api_management_gateway_regional_url
}

output "api_management_management_api_url" {
  description = "The URL for the Management API associated with this API Management service"
  value       = module.apim.api_management_management_api_url
}

output "api_management_portal_url" {
  description = "The URL for the Publisher Portal associated with this API Management service"
  value       = module.apim.api_management_portal_url
}

output "api_management_public_ip_addresses" {
  description = "The Public IP addresses of the API Management Service"
  value       = module.apim.api_management_public_ip_addresses
}

output "api_management_private_ip_addresses" {
  description = "The Private IP addresses of the API Management Service"
  value       = module.apim.api_management_private_ip_addresses
}

output "api_management_scm_url" {
  description = "The URL for the SCM Endpoint associated with this API Management service"
  value       = module.apim.api_management_scm_url
}

output "api_management_identity" {
  description = "The identity of the API Management"
  value       = module.apim.api_management_identity
}

output "public_ip_address" {
  value = module.public_ip.ip_address
}

output "resource_group_name" {
  value = var.resource_group_name != null ? var.resource_group_name : module.resource_group[0].name
}
