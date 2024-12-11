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

variable "tags" {
  description = "A mapping of tags to assign to the resource."
  type        = map(string)
  default     = {}
}
