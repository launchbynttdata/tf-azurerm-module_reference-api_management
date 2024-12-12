# public_serverless

Please set a provider block with the following, to avoid soft-deletes of the APIM instance which can cause problems with the tests
```
provider "azurerm" {
  features {
    api_management {
      purge_soft_delete_on_destroy = true
      recover_soft_deleted         = true
    }
  }
}
```


<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | ~> 1.0 |
| <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) | ~>3.67 |

## Providers

No providers.

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_resource_names"></a> [resource\_names](#module\_resource\_names) | terraform.registry.launch.nttdata.com/module_library/resource_name/launch | ~> 1.0 |
| <a name="module_resource_group"></a> [resource\_group](#module\_resource\_group) | terraform.registry.launch.nttdata.com/module_primitive/resource_group/azurerm | ~> 1.0 |
| <a name="module_virtual_network"></a> [virtual\_network](#module\_virtual\_network) | terraform.registry.launch.nttdata.com/module_primitive/virtual_network/azurerm | ~> 3.0 |
| <a name="module_apim"></a> [apim](#module\_apim) | ../.. | n/a |

## Resources

No resources.

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_product_family"></a> [product\_family](#input\_product\_family) | (Required) Name of the product family for which the resource is created.<br>    Example: org\_name, department\_name. | `string` | `"dso"` | no |
| <a name="input_product_service"></a> [product\_service](#input\_product\_service) | (Required) Name of the product service for which the resource is created.<br>    For example, backend, frontend, middleware etc. | `string` | `"apim"` | no |
| <a name="input_environment"></a> [environment](#input\_environment) | Environment in which the resource should be provisioned like dev, qa, prod etc. | `string` | `"dev"` | no |
| <a name="input_environment_number"></a> [environment\_number](#input\_environment\_number) | The environment count for the respective environment. Defaults to 000. Increments in value of 1 | `string` | `"000"` | no |
| <a name="input_resource_number"></a> [resource\_number](#input\_resource\_number) | The resource count for the respective resource. Defaults to 000. Increments in value of 1 | `string` | `"000"` | no |
| <a name="input_region"></a> [region](#input\_region) | Azure Region in which the infra needs to be provisioned | `string` | `"eastus"` | no |
| <a name="input_resource_names_map"></a> [resource\_names\_map](#input\_resource\_names\_map) | A map of key to resource\_name that will be used by tf-launch-module\_library-resource\_name to generate resource names | <pre>map(object(<br>    {<br>      name       = string<br>      max_length = optional(number, 60)<br>    }<br>  ))</pre> | <pre>{<br>  "resource_group": {<br>    "max_length": 60,<br>    "name": "rg"<br>  },<br>  "virtual_network": {<br>    "name": "vnet"<br>  }<br>}</pre> | no |
| <a name="input_address_prefix"></a> [address\_prefix](#input\_address\_prefix) | The address space that is used by the virtual network. | `string` | `"10.6.0.0/16"` | no |
| <a name="input_sku_name"></a> [sku\_name](#input\_sku\_name) | String consisting of two parts separated by an underscore. The fist part is the name, valid values include: Developer,<br>    Basic, Standard and Premium. The second part is the capacity. Default is Developer\_1. | `string` | `"Developer_1"` | no |
| <a name="input_publisher_name"></a> [publisher\_name](#input\_publisher\_name) | The name of publisher/company. | `string` | n/a | yes |
| <a name="input_publisher_email"></a> [publisher\_email](#input\_publisher\_email) | The email of publisher/company. | `string` | n/a | yes |
| <a name="input_public_network_access_enabled"></a> [public\_network\_access\_enabled](#input\_public\_network\_access\_enabled) | Should the API Management Service be accessible from the public internet?<br>    This option is applicable only to the Management plane, not the API gateway or Developer portal.<br>    It is required to be true on the creation.<br>    For sku=Developer/Premium and network\_type=Internal, it must be true.<br>    It can only be set to false if there is at least one approve private endpoint connection. | `bool` | `true` | no |
| <a name="input_virtual_network_type"></a> [virtual\_network\_type](#input\_virtual\_network\_type) | The type of virtual network you want to use, valid values include: None, External, Internal.<br>    External and Internal are only supported in the SKUs - Premium and Developer | `string` | `"None"` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | A mapping of tags to assign to the resource. | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_api_management_name"></a> [api\_management\_name](#output\_api\_management\_name) | The name of the API Management Service |
| <a name="output_api_management_id"></a> [api\_management\_id](#output\_api\_management\_id) | The ID of the API Management Service |
| <a name="output_api_management_additional_location"></a> [api\_management\_additional\_location](#output\_api\_management\_additional\_location) | Map listing gateway\_regional\_url and public\_ip\_addresses associated |
| <a name="output_api_management_gateway_url"></a> [api\_management\_gateway\_url](#output\_api\_management\_gateway\_url) | The URL of the Gateway for the API Management Service |
| <a name="output_api_management_gateway_regional_url"></a> [api\_management\_gateway\_regional\_url](#output\_api\_management\_gateway\_regional\_url) | The Region URL for the Gateway of the API Management Service |
| <a name="output_api_management_management_api_url"></a> [api\_management\_management\_api\_url](#output\_api\_management\_management\_api\_url) | The URL for the Management API associated with this API Management service |
| <a name="output_api_management_portal_url"></a> [api\_management\_portal\_url](#output\_api\_management\_portal\_url) | The URL for the Publisher Portal associated with this API Management service |
| <a name="output_api_management_public_ip_addresses"></a> [api\_management\_public\_ip\_addresses](#output\_api\_management\_public\_ip\_addresses) | The Public IP addresses of the API Management Service |
| <a name="output_api_management_private_ip_addresses"></a> [api\_management\_private\_ip\_addresses](#output\_api\_management\_private\_ip\_addresses) | The Private IP addresses of the API Management Service |
| <a name="output_api_management_scm_url"></a> [api\_management\_scm\_url](#output\_api\_management\_scm\_url) | The URL for the SCM Endpoint associated with this API Management service |
| <a name="output_api_management_identity"></a> [api\_management\_identity](#output\_api\_management\_identity) | The identity of the API Management |
| <a name="output_public_ip_address"></a> [public\_ip\_address](#output\_public\_ip\_address) | n/a |
| <a name="output_resource_group_name"></a> [resource\_group\_name](#output\_resource\_group\_name) | n/a |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
