# For certification_configuration, the `ca.cer` must be present in the same directory as the main.tf file

product_family                = "dso"
product_service               = "apim"
region                        = "eastus"
sku_name                      = "Developer_1"
publisher_name                = "<Name>"
publisher_email               = "<email_id>"
virtual_network_type          = "Internal"
virtual_network_configuration = ["<subnet_id>"]

certificate_configuration = [{
  encoded_certificate  = "ca.cer"
  certificate_password = null
  store_name           = "Root"
}]

# While creation, this must be true. On subsequent runs, this must be false
public_network_access_enabled = true

additional_vnet_links = {}
