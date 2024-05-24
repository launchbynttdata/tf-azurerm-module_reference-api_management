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
  vnet_id = length(var.virtual_network_configuration) > 0 ? join("/", slice(split("/", var.virtual_network_configuration[0]), 0, 9)) : null

  apim_vnet_link = {
    private-apim-vnet-link = local.vnet_id
  }

  all_vnet_links = merge(local.apim_vnet_link, var.additional_vnet_links)

  default_tags = {
    provisioner = "Terraform"
  }

  tags = merge(local.default_tags, var.tags)
}
