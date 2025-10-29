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

data "azurerm_client_config" "current" {
  # This data source is used to get the current Azure client configuration
  # which includes the object ID of the service principal or user running the Terraform code.
}

module "resource_names" {
  source  = "terraform.registry.launch.nttdata.com/module_library/resource_name/launch"
  version = "~> 2.0"

  for_each = var.resource_names_map

  logical_product_family  = var.product_family
  logical_product_service = var.product_service
  region                  = var.region
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

  name     = module.resource_names["resource_group"].minimal_random_suffix
  location = var.region

  tags = merge(var.tags, { resource_name = module.resource_names["resource_group"].standard })
}

module "log_analytics_workspace" {
  source  = "terraform.registry.launch.nttdata.com/module_primitive/log_analytics_workspace/azurerm"
  version = "~> 1.0"

  name                = module.resource_names["log_analytics_workspace"].minimal_random_suffix
  resource_group_name = module.resource_group.name
  location            = var.region

  tags = merge(var.tags, { resource_name = module.resource_names["log_analytics_workspace"].standard })

  depends_on = [module.resource_group]
}

module "app_insights" {
  source  = "terraform.registry.launch.nttdata.com/module_primitive/application_insights/azurerm"
  version = "~> 1.0"

  name                = module.resource_names["app_insights"].minimal_random_suffix
  resource_group_name = module.resource_group.name
  location            = var.region

  // app insights module is not idempotent unless the workspace_id is set
  // otherwise Azure will create a new workspace which terraform is not aware of
  workspace_id = module.log_analytics_workspace.id

  tags = merge(var.tags, { resource_name = module.resource_names["app_insights"].standard })

  depends_on = [module.log_analytics_workspace]
}

module "certificate_deployment_role_assignment" {
  source  = "terraform.registry.launch.nttdata.com/module_primitive/role_assignment/azurerm"
  version = "~> 1.0"

  principal_id         = data.azurerm_client_config.current.object_id
  principal_type       = var.use_service_principal ? "ServicePrincipal" : "User"
  role_definition_name = "Key Vault Administrator"
  scope                = module.resource_group.id

  depends_on = [module.resource_group]
}

module "key_vault" {
  source  = "terraform.registry.launch.nttdata.com/module_primitive/key_vault/azurerm"
  version = "~> 2.1"

  key_vault_name = module.resource_names["key_vault"].minimal_random_suffix
  resource_group = {
    name     = module.resource_group.name
    location = var.region
  }

  enable_rbac_authorization = true

  custom_tags = merge(var.tags, { resource_name = module.resource_names["key_vault"].standard })

  depends_on = [module.certificate_deployment_role_assignment]
}

module "key_vault_certificate" {
  source  = "terraform.registry.launch.nttdata.com/module_primitive/key_vault_certificate/azurerm"
  version = "~> 1.0"

  name         = "terratest-certificate"
  key_vault_id = module.key_vault.key_vault_id

  method      = "Generate"
  issuer_name = "Self"

  x509_certificate_properties = {
    key_usage          = ["digitalSignature", "nonRepudiation", "keyCertSign", "keyEncipherment", "dataEncipherment"]
    subject            = "CN=Launch DSO Test Certificate"
    validity_in_months = 12
    subject_alternate_names = {
      emails    = ["test@launchdso.nttdata.com"]
      dns_names = ["launchdso.nttdata.com"]
    }
  }

  tags = var.tags

  depends_on = [module.key_vault]
}

locals {
  apis_with_content = {
    for name, api in var.apis :
    name => merge(api, {
      import = api.import != null ? {
        content_format = api.import.content_format
        content_value  = file(api.import.content_value)
      } : null,
      policy = api.policy != null ? {
        xml_content = file(api.policy.xml_content)
      } : null
    })
  }
}

module "apim" {
  source = "../.."

  product_family     = var.product_family
  product_service    = var.product_service
  environment        = var.environment
  environment_number = var.environment_number
  resource_number    = var.resource_number
  region             = var.region

  resource_names_map = var.resource_names_map

  identity_type = "SystemAssigned"

  sku_name        = var.sku_name
  publisher_name  = var.publisher_name
  publisher_email = var.publisher_email

  public_network_access_enabled = var.public_network_access_enabled

  apis = merge(local.apis_with_content, {
    "terratest-api" = {
      display_name          = "Terratest API"
      description           = "This is a test API for Terratest"
      path                  = "terratest/v1/resource"
      subscription_required = false

      import = {
        content_format = "swagger-json"
        content_value  = file("terratest-api.json")
      }
      policy = {
        xml_content = file("terratest-api.policy.xml")
      }
    }
  })
  backends = merge(var.backends, {
    "terratest-backend" = {
      url = "https://launchdso.nttdata.com"
      credentials = {
        certificate = ["terratest-certificate"]
      }
    }
  })
  certificates = merge(var.certificates, {
    "terratest-certificate" = {
      key_vault_secret_id = module.key_vault_certificate.secret_id
    }
  })
  diagnostics = merge(var.diagnostics, {
    "terratest-diagnostic" = {
      identifier  = "applicationinsights"
      api_name    = "terratest-api"
      logger_name = "terratest-logger"
      backend_request = {
        bytes_to_log   = 8192
        headers_to_log = ["X-Terratest-Header"]
      }
      frontend_request = {
        bytes_to_log   = 0
        headers_to_log = ["X-Forwarded-For"]
      }
    }
  })
  loggers = merge(var.loggers, {
    "terratest-logger" = {
      application_insights = {
        instrumentation_key = module.app_insights.instrumentation_key
      }
    }
  })
  named_values = merge(var.named_values, {
    "terratest-named-value" = {
      value  = "0123456789abcdef"
      secret = false
    }
  })

  key_vaults = {
    "example-key-vault" = module.key_vault.key_vault_id
  }

  tags = var.tags

  depends_on = [
    module.app_insights,
    module.key_vault_certificate
  ]
}
