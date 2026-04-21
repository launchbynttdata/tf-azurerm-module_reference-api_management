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


<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | ~> 1.0 |
| <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) | ~>3.117 |
| <a name="requirement_random"></a> [random](#requirement\_random) | ~> 3.7 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) | 3.117.1 |
| <a name="provider_random"></a> [random](#provider\_random) | 3.8.1 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_resource_names"></a> [resource\_names](#module\_resource\_names) | terraform.registry.launch.nttdata.com/module_library/resource_name/launch | ~> 2.0 |
| <a name="module_resource_group"></a> [resource\_group](#module\_resource\_group) | terraform.registry.launch.nttdata.com/module_primitive/resource_group/azurerm | ~> 1.0 |
| <a name="module_log_analytics_workspace"></a> [log\_analytics\_workspace](#module\_log\_analytics\_workspace) | terraform.registry.launch.nttdata.com/module_primitive/log_analytics_workspace/azurerm | ~> 1.0 |
| <a name="module_app_insights"></a> [app\_insights](#module\_app\_insights) | terraform.registry.launch.nttdata.com/module_primitive/application_insights/azurerm | ~> 1.0 |
| <a name="module_certificate_deployment_role_assignment"></a> [certificate\_deployment\_role\_assignment](#module\_certificate\_deployment\_role\_assignment) | terraform.registry.launch.nttdata.com/module_primitive/role_assignment/azurerm | ~> 1.0 |
| <a name="module_key_vault"></a> [key\_vault](#module\_key\_vault) | terraform.registry.launch.nttdata.com/module_primitive/key_vault/azurerm | ~> 2.1 |
| <a name="module_key_vault_certificate"></a> [key\_vault\_certificate](#module\_key\_vault\_certificate) | terraform.registry.launch.nttdata.com/module_primitive/key_vault_certificate/azurerm | ~> 1.0 |
| <a name="module_apim"></a> [apim](#module\_apim) | ../.. | n/a |

## Resources

| Name | Type |
|------|------|
| [random_integer.resource_number](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/integer) | resource |
| [azurerm_client_config.current](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/client_config) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_product_family"></a> [product\_family](#input\_product\_family) | (Required) Name of the product family for which the resource is created.<br>    Example: org\_name, department\_name. | `string` | `"dso"` | no |
| <a name="input_product_service"></a> [product\_service](#input\_product\_service) | (Required) Name of the product service for which the resource is created.<br>    For example, backend, frontend, middleware etc. | `string` | `"apimpublic"` | no |
| <a name="input_environment"></a> [environment](#input\_environment) | Environment in which the resource should be provisioned like dev, qa, prod etc. | `string` | `"dev"` | no |
| <a name="input_environment_number"></a> [environment\_number](#input\_environment\_number) | The environment count for the respective environment. Defaults to 000. Increments in value of 1 | `string` | `"001"` | no |
| <a name="input_region"></a> [region](#input\_region) | Azure Region in which the infra needs to be provisioned | `string` | `"eastus"` | no |
| <a name="input_resource_names_map"></a> [resource\_names\_map](#input\_resource\_names\_map) | A map of key to resource\_name that will be used by tf-launch-module\_library-resource\_name to generate resource names | <pre>map(object(<br>    {<br>      name       = string<br>      max_length = optional(number, 60)<br>    }<br>  ))</pre> | <pre>{<br>  "apim": {<br>    "max_length": 60,<br>    "name": "apim"<br>  },<br>  "app_insights": {<br>    "max_length": 60,<br>    "name": "appi"<br>  },<br>  "key_vault": {<br>    "max_length": 24,<br>    "name": "kv"<br>  },<br>  "log_analytics_workspace": {<br>    "max_length": 60,<br>    "name": "law"<br>  },<br>  "nsg": {<br>    "max_length": 60,<br>    "name": "nsg"<br>  },<br>  "public_ip": {<br>    "max_length": 60,<br>    "name": "pip"<br>  },<br>  "resource_group": {<br>    "max_length": 60,<br>    "name": "rg"<br>  },<br>  "user_assigned_identity": {<br>    "max_length": 60,<br>    "name": "uai"<br>  }<br>}</pre> | no |
| <a name="input_sku_name"></a> [sku\_name](#input\_sku\_name) | String consisting of two parts separated by an underscore. The fist part is the name, valid values include: Developer,<br>    Basic, Standard and Premium. The second part is the capacity. Default is Developer\_1. | `string` | `"Developer_1"` | no |
| <a name="input_publisher_name"></a> [publisher\_name](#input\_publisher\_name) | The name of publisher/company. | `string` | n/a | yes |
| <a name="input_publisher_email"></a> [publisher\_email](#input\_publisher\_email) | The email of publisher/company. | `string` | n/a | yes |
| <a name="input_public_network_access_enabled"></a> [public\_network\_access\_enabled](#input\_public\_network\_access\_enabled) | Should the API Management Service be accessible from the public internet?<br>    This option is applicable only to the Management plane, not the API gateway or Developer portal.<br>    It is required to be true on the creation.<br>    For sku=Developer/Premium and network\_type=Internal, it must be true.<br>    It can only be set to false if there is at least one approve private endpoint connection. | `bool` | `true` | no |
| <a name="input_apis"></a> [apis](#input\_apis) | A map of API definitions to be created in the API Management Service. The key is the API name and the value is the API definition. | <pre>map(object({<br>    display_name          = string<br>    path                  = string<br>    description           = string<br>    protocols             = optional(list(string), ["https"])<br>    api_type              = optional(string, "http")<br>    service_url           = optional(string, null)<br>    soap_pass_through     = optional(bool, null)<br>    subscription_required = optional(bool, true)<br>    terms_of_service_url  = optional(string, null)<br><br>    contact = optional(object({<br>      name  = string<br>      email = string<br>      url   = string<br>    }), null)<br><br>    import = optional(object({<br>      content_format = string<br>      content_value  = optional(string, null)<br>      content_url    = optional(string, null)<br>    }), null)<br><br>    license = optional(object({<br>      name = string<br>      url  = string<br>    }), null)<br><br>    policy = optional(object({<br>      xml_content = optional(string, null)<br>      xml_link    = optional(string, null)<br>    }), null)<br><br>    operations = optional(list(object({<br>      operation_id = string<br>      display_name = string<br>      method       = string<br>      url_template = string<br>      description  = string<br>    })))<br>    operation_policies = optional(list(object({<br>      operation_id = string<br>      xml_content  = string<br>    })))<br>  }))</pre> | `{}` | no |
| <a name="input_backends"></a> [backends](#input\_backends) | A map of backend definitions to be created in the API Management Service. The key is the backend name and the value is the backend definition. | <pre>map(object({<br>    url = string<br><br>    description = optional(string, null)<br>    title       = optional(string, null)<br>    protocol    = optional(string, "http")<br><br>    credentials = object({<br>      authorization = optional(object({<br>        scheme    = string<br>        parameter = string<br>      }), null)<br>      certificate = optional(list(string), null)<br>      query       = optional(map(string), null)<br>      header      = optional(map(string), null)<br>    })<br><br>    proxy = optional(object({<br>      url      = string<br>      username = string<br>      password = optional(string)<br>    }), null)<br><br>    service_fabric_cluster = optional(object({<br>      client_certificate_thumbprint    = optional(string, null)<br>      client_certificate_id            = optional(string, null)<br>      management_endpoints             = list(string)<br>      max_partition_resolution_retries = number<br>      server_certificate_thumbprints   = optional(list(string), null)<br>      server_x509_names = optional(list(object({<br>        issuer_certificate_thumbprint = string<br>        name                          = string<br>      })), null)<br>    }), null)<br><br>    tls = optional(object({<br>      validate_certificate_name  = optional(bool, true)<br>      validate_certificate_chain = optional(bool, true)<br>    }), null)<br><br>    resource_id = optional(string, null)<br>  }))</pre> | `{}` | no |
| <a name="input_certificates"></a> [certificates](#input\_certificates) | A map of certificate definitions to be created in the API Management Service. The key is the certificate name and the value is the certificate definition. | <pre>map(object({<br>    data                         = optional(string, null)<br>    password                     = optional(string, null)<br>    key_vault_secret_id          = optional(string, null)<br>    key_vault_identity_client_id = optional(string, null)<br>  }))</pre> | `{}` | no |
| <a name="input_diagnostics"></a> [diagnostics](#input\_diagnostics) | A map of diagnostics definitions to be created in the API Management Service. The key is the diagnostic identifier and the value is the diagnostic definition. | <pre>map(object({<br>    identifier                = string<br>    logger_name               = string<br>    api_name                  = optional(string, null)<br>    always_log_errors         = optional(bool, false)<br>    http_correlation_protocol = optional(string, "W3C")<br>    operation_name_format     = optional(string, "Name")<br>    log_client_ip             = optional(bool, false)<br>    sampling_percentage       = optional(number, 100)<br>    verbosity                 = optional(string, "error")<br>    frontend_request = optional(object({<br>      body_bytes     = optional(number, 0)<br>      headers_to_log = optional(list(string), [])<br>    }), {})<br>    frontend_response = optional(object({<br>      body_bytes     = optional(number, 0)<br>      headers_to_log = optional(list(string), [])<br>    }), {})<br>    backend_request = optional(object({<br>      body_bytes     = optional(number, 0)<br>      headers_to_log = optional(list(string), [])<br>    }), {})<br>    backend_response = optional(object({<br>      body_bytes     = optional(number, 0)<br>      headers_to_log = optional(list(string), [])<br>    }), {})<br>  }))</pre> | `{}` | no |
| <a name="input_loggers"></a> [loggers](#input\_loggers) | A map of logger definitions to be created in the API Management Service. The key is the logger name and the value is the logger definition. | <pre>map(object({<br>    description = optional(string, null)<br>    buffered    = optional(bool, true)<br><br>    application_insights = optional(object({<br>      instrumentation_key = string<br>    }), null)<br><br>    eventhub = optional(object({<br>      name                             = string<br>      connection_string                = optional(string, null)<br>      user_assigned_identity_client_id = optional(string, null)<br>      endpoint_uri                     = optional(string, null)<br>    }), null)<br>  }))</pre> | `{}` | no |
| <a name="input_named_values"></a> [named\_values](#input\_named\_values) | A map of named value definitions to be created in the API Management Service. | <pre>map(object({<br>    display_name = optional(string, null)<br>    value        = optional(string, null)<br>    secret       = optional(bool, false)<br>    value_from_key_vault = optional(object({<br>      secret_id          = string<br>      identity_client_id = optional(string, null)<br>    }), null)<br>  }))</pre> | `{}` | no |
| <a name="input_use_service_principal"></a> [use\_service\_principal](#input\_use\_service\_principal) | Set to false when running locally without a service principal | `bool` | `true` | no |
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
<!-- END_TF_DOCS -->
