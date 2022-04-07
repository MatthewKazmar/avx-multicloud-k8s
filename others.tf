# Create resources that are one-offs

resource "azurerm_resource_group" "aks" {
  name     = var.azure_rg_name
  location = local.azurerm_azure_region
}

module "azure_region" {
  source = "claranet/regions/azurerm"

  azure_region = var.azure_region
}