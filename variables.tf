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
variable "product_family" {
  description = <<EOF
    (Required) Name of the product family for which the resource is created.
    Example: org_name, department_name.
  EOF
  type        = string
  default     = "dso"
}

variable "product_service" {
  description = <<EOF
    (Required) Name of the product service for which the resource is created.
    For example, backend, frontend, middleware etc.
  EOF
  type        = string
  default     = "apim"
}

variable "environment" {
  description = "Environment in which the resource should be provisioned like dev, qa, prod etc."
  type        = string
  default     = "dev"
}

variable "environment_number" {
  description = "The environment count for the respective environment. Defaults to 000. Increments in value of 1"
  type        = string
  default     = "000"
}

variable "resource_number" {
  description = "The resource count for the respective resource. Defaults to 000. Increments in value of 1"
  type        = string
  default     = "000"
}

variable "region" {
  description = "Azure Region in which the infra needs to be provisioned"
  type        = string
  default     = "eastus"
}

variable "resource_names_map" {
  description = "A map of key to resource_name that will be used by tf-launch-module_library-resource_name to generate resource names"
  type = map(object(
    {
      name       = string
      max_length = optional(number, 60)
    }
  ))
  default = {
    apim = {
      name       = "apim"
      max_length = 60
    }
    public_ip = {
      name       = "pip"
      max_length = 60
    }
    resource_group = {
      name       = "rg"
      max_length = 60
    }
    nsg = {
      name       = "nsg"
      max_length = 60
    }
    key_vault = {
      name       = "kv"
      max_length = 24
    }
  }
}

variable "resource_group_name" {
  description = "Name of the resource group. If not specified, this module will create a resource group."
  type        = string
  default     = null
}

variable "resource_names_version" {
  description = "Major version of the resource names module to use"
  type        = string
  default     = "1"
}

variable "sku_name" {
  type        = string
  description = <<EOT
    String consisting of two parts separated by an underscore. The fist part is the name, valid values include: Developer,
    Basic, Standard and Premium. The second part is the capacity. Default is Developer_1.
  EOT
  default     = "Developer_1"
}

variable "publisher_name" {
  type        = string
  description = "The name of publisher/company."
}

variable "publisher_email" {
  type        = string
  description = "The email of publisher/company."
}

variable "additional_location" {
  type        = list(map(string))
  description = "List of the name of the Azure Region in which the API Management Service should be expanded to."
  default     = []
}

variable "zones" {
  type        = list(number)
  description = <<EOT
    (Optional) Specifies a list of Availability Zones in which this API Management service should be located. Changing this
    forces a new API Management service to be created. Supported in Premium Tier.
  EOT
  default     = []
}

variable "certificate_configuration" {
  type = list(object({
    encoded_certificate  = string
    certificate_password = string
    store_name           = string
  }))
  description = <<EOT
    List of certificate configurations. The Certificate must be base encoded pfx or pem format. `certificate_password` can be null if
    not present. `store_name` can be `CertificateAuthority` or `Root`.
  EOT
  default     = []
}

variable "client_certificate_enabled" {
  type        = bool
  description = "(Optional) Enforce a client certificate to be presented on each request to the gateway? This is only supported when SKU type is `Consumption`."
  default     = false
}

variable "gateway_disabled" {
  type        = bool
  description = "(Optional) Disable the gateway in main region? This is only supported when `additional_location` is set."
  default     = false
}

variable "min_api_version" {
  type        = string
  description = "(Optional) The version which the control plane API calls to API Management service are limited with version equal to or newer than."
  default     = null
}

variable "enable_http2" {
  type        = bool
  description = "Should HTTP/2 be supported by the API Management Service?"
  default     = false
}

variable "management_hostname_configuration" {
  type        = list(map(string))
  description = "List of management hostname configurations"
  default     = []
}

variable "scm_hostname_configuration" {
  type        = list(map(string))
  description = "List of scm hostname configurations"
  default     = []
}

variable "proxy_hostname_configuration" {
  type        = list(map(string))
  description = "List of proxy hostname configurations"
  default     = []
}

variable "portal_hostname_configuration" {
  type        = list(map(string))
  description = "Legacy portal hostname configurations"
  default     = []
}

variable "developer_portal_hostname_configuration" {
  type        = list(map(string))
  description = "Developer portal hostname configurations"
  default     = []
}

variable "notification_sender_email" {
  type        = string
  description = "Email address from which the notification will be sent"
  default     = null
}

variable "policy_configuration" {
  type        = map(string)
  description = "Map of policy configuration"
  default     = {}
}

variable "public_network_access_enabled" {
  description = <<EOT
    Should the API Management Service be accessible from the public internet?
    This option is applicable only to the Management plane, not the API gateway or Developer portal.
    It is required to be true on the creation.
    For sku=Developer/Premium and network_type=Internal, it must be true.
    It can only be set to false if there is at least one approve private endpoint connection.
  EOT
  type        = bool
  default     = true
}

variable "enable_sign_in" {
  type        = bool
  description = "Should anonymous users be redirected to the sign in page?"
  default     = false
}

variable "enable_sign_up" {
  type        = bool
  description = "Can users sign up on the development portal?"
  default     = false
}

variable "terms_of_service_configuration" {
  type        = list(map(string))
  description = "Map of terms of service configuration"

  default = [{
    consent_required = false
    enabled          = false
    text             = ""
  }]
}

variable "security_configuration" {
  type        = map(string)
  description = "Map of security configuration"
  default     = {}
}

### NETWORKING

variable "virtual_network_type" {
  type        = string
  description = <<EOT
    The type of virtual network you want to use, valid values include: None, External, Internal.
    External and Internal are only supported in the SKUs - Premium and Developer
  EOT
  default     = "None"
}

variable "virtual_network_configuration" {
  type        = list(string)
  description = <<EOT
    The id(s) of the subnet(s) that will be used for the API Management. Required when virtual_network_type is External or Internal
    that is in the SKUs - Premium and Developer
  EOT
  default     = []
}

variable "additional_nsg_rules" {
  description = <<EOT
    A list of additional NSG rules to be applied to the API Management subnet. Only applicable when virtual_network_type
    is External or Internal.
    Use `priority` > 105 to avoid conflicts with default rules.
  EOT
  type = list(object({
    name                       = string
    priority                   = number
    direction                  = string
    access                     = string
    protocol                   = string
    source_port_range          = string
    destination_port_range     = string
    source_address_prefix      = string
    destination_address_prefix = string
  }))

  default = []
}

### SUBRESOURCES
variable "apis" {
  description = "A map of API definitions to be created in the API Management Service. The key is the API name and the value is the API definition."
  type = map(object({
    display_name          = string
    path                  = string
    description           = string
    protocols             = optional(list(string), ["https"])
    api_type              = optional(string, "http")
    service_url           = optional(string, null)
    soap_pass_through     = optional(bool, null)
    subscription_required = optional(bool, true)
    terms_of_service_url  = optional(string, null)

    contact = optional(object({
      name  = string
      email = string
      url   = string
    }), null)

    import = optional(object({
      content_format = string
      content_value  = string
    }), null)

    license = optional(object({
      name = string
      url  = string
    }), null)

    policy = optional(object({
      xml_content = optional(string, null)
      xml_link    = optional(string, null)
    }), null)
  }))
  default = {}
}

variable "backends" {
  description = "A map of backend definitions to be created in the API Management Service. The key is the backend name and the value is the backend definition."
  type = map(object({
    url = string

    description = optional(string, null)
    title       = optional(string, null)
    protocol    = optional(string, "http")

    credentials = object({
      authorization = optional(object({
        scheme    = string
        parameter = string
      }), null)
      certificate = optional(list(string), null)
      query       = optional(map(string), null)
      header      = optional(map(string), null)
    })

    proxy = optional(object({
      url      = string
      username = string
      password = optional(string)
    }), null)

    service_fabric_cluster = optional(object({
      client_certificate_thumbprint    = optional(string, null)
      client_certificate_id            = optional(string, null)
      management_endpoints             = list(string)
      max_partition_resolution_retries = number
      server_certificate_thumbprints   = optional(list(string), null)
      server_x509_names = optional(list(object({
        issuer_certificate_thumbprint = string
        name                          = string
      })), null)
    }), null)

    tls = optional(object({
      validate_certificate_name  = optional(bool, true)
      validate_certificate_chain = optional(bool, true)
    }), null)

    resource_id = optional(string, null)
  }))
  default = {}
}

variable "certificates" {
  description = "A map of certificate definitions to be created in the API Management Service. The key is the certificate name and the value is the certificate definition."
  type = map(object({
    data                         = optional(string, null)
    password                     = optional(string, null)
    key_vault_secret_id          = optional(string, null)
    key_vault_identity_client_id = optional(string, null)
  }))
  default = {}
}

variable "diagnostics" {
  description = "A map of diagnostics definitions to be created in the API Management Service. The key is the diagnostic identifier and the value is the diagnostic definition."
  type = map(object({
    identifier                = string
    logger_name               = string
    api_name                  = optional(string, null)
    always_log_errors         = optional(bool, false)
    http_correlation_protocol = optional(string, "W3C")
    operation_name_format     = optional(string, "Name")
    log_client_ip             = optional(bool, false)
    sampling_percentage       = optional(number, 100)
    verbosity                 = optional(string, "error")
    frontend_request = optional(object({
      body_bytes     = optional(number, 0)
      headers_to_log = optional(list(string), [])
    }), {})
    frontend_response = optional(object({
      body_bytes     = optional(number, 0)
      headers_to_log = optional(list(string), [])
    }), {})
    backend_request = optional(object({
      body_bytes     = optional(number, 0)
      headers_to_log = optional(list(string), [])
    }), {})
    backend_response = optional(object({
      body_bytes     = optional(number, 0)
      headers_to_log = optional(list(string), [])
    }), {})
  }))
  default = {}
}

variable "loggers" {
  description = "A map of logger definitions to be created in the API Management Service. The key is the logger name and the value is the logger definition."
  type = map(object({
    description = optional(string, null)
    buffered    = optional(bool, true)

    application_insights = optional(object({
      instrumentation_key = string
    }), null)

    eventhub = optional(object({
      name                             = string
      connection_string                = optional(string, null)
      user_assigned_identity_client_id = optional(string, null)
      endpoint_uri                     = optional(string, null)
    }), null)
  }))
  default = {}
}

### IDENTITY

variable "identity_type" {
  description = "Type of Managed Service Identity that should be configured on this API Management Service"
  type        = string
  default     = "SystemAssigned"
}

variable "identity_ids" {
  description = "A list of IDs for User Assigned Managed Identity resources to be assigned. This is required when type is set to UserAssigned or SystemAssigned, UserAssigned."
  type        = list(string)
  default     = []
}

variable "dns_zone_suffix" {
  description = <<EOT
    The DNS Zone suffix for APIM private DNS Zone. Default is `azure-api.net` for Public Cloud
    For gov cloud it may be different
  EOT
  type        = string
  default     = "azure-api.net"
}

variable "default_ttl" {
  description = "The default TTL for the DNS Zone"
  type        = number
  default     = 300
}

variable "additional_vnet_links" {
  description = "A list of VNET IDs for which vnet links to be created with the private AKS cluster DNS Zone. Applicable only when network_type=Internal"
  type        = map(string)
  default     = {}
}

variable "tags" {
  description = "A mapping of tags to assign to the resource."
  type        = map(string)
  default     = {}
}
