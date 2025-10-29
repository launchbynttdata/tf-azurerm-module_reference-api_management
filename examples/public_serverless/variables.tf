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
  default     = "apimpublic"
}

variable "environment" {
  description = "Environment in which the resource should be provisioned like dev, qa, prod etc."
  type        = string
  default     = "dev"
}

variable "environment_number" {
  description = "The environment count for the respective environment. Defaults to 000. Increments in value of 1"
  type        = string
  default     = "001"
}

variable "resource_number" {
  description = "The resource count for the respective resource. Defaults to 000. Increments in value of 1"
  type        = string
  default     = "001"
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
    app_insights = {
      name       = "appi"
      max_length = 60
    }
    log_analytics_workspace = {
      name       = "law"
      max_length = 60
    }
    user_assigned_identity = {
      name       = "uai"
      max_length = 60
    }
  }
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
      content_value  = optional(string, null)
      content_url    = optional(string, null)
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

variable "named_values" {
  description = "A map of named value definitions to be created in the API Management Service."
  type = map(object({
    display_name = optional(string, null)
    value        = optional(string, null)
    secret       = optional(bool, false)
    value_from_key_vault = optional(object({
      secret_id          = string
      identity_client_id = optional(string, null)
    }), null)
  }))
  default = {}
}

variable "use_service_principal" {
  description = "Set to false when running locally without a service principal"
  type        = bool
  default     = true
}

variable "tags" {
  description = "A mapping of tags to assign to the resource."
  type        = map(string)
  default     = {}
}
