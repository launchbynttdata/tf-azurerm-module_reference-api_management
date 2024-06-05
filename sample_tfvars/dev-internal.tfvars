# For certification_configuration, the `ca.cer` must be present in the same directory as the main.tf file

product_family                = "dso"
product_service               = "apim"
region                        = "eastus"
sku_name                      = "Developer_1"
publisher_name                = "<publisher_name>"
publisher_email               = "<publisher_name>@<org>.com"
virtual_network_type          = "Internal"
virtual_network_configuration = ["<vnet_id>"]

# Encoded certificate `ca.cer` must be present in the same path as the main.tf file or the terragrunt.hcl in case of terragrunt
certificate_configuration = [{
  encoded_certificate  = "ca.cer"
  certificate_password = null
  store_name           = "Root"
}]

# While creation, this must be true. For sku=Developer/Premium and network_type=Internal, it must be true.
public_network_access_enabled = true

additional_vnet_links = {
  #bastion-vnet-link = "<vnet_id>"
}
