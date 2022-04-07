# Deploy AKS

resource "azurerm_kubernetes_cluster" "aks" {
  name                      = "aks-cluster"
  location                  = local.azurerm_azure_region
  resource_group_name       = var.azure_rg_name
  dns_prefix                = "aks"
  private_cluster_enabled   = false
  automatic_channel_upgrade = "stable"

  default_node_pool {
    name           = "default"
    node_count     = var.node_count
    vm_size        = var.azure_node_size
    vnet_subnet_id = module.azure_vnet.vnet_subnets[1]
  }

  identity {
    type = "SystemAssigned"
  }

  network_profile {
    network_plugin     = "azure"
    service_cidr       = local.azure_service_cidr
    dns_service_ip     = cidrhost(local.azure_service_cidr, 2)
    docker_bridge_cidr = local.azure_docker_bridge_cidr
  }

  depends_on = [
    module.azure_vnet
  ]
}


resource "null_resource" "get_aks_creds" {
  triggers = {
    fqdn = azurerm_kubernetes_cluster.aks.fqdn
  }
  provisioner "local-exec" {
    command = "az aks get-credentials --resource-group ${var.azure_rg_name} --name aks-cluster"
  }
  depends_on = [
    azurerm_kubernetes_cluster.aks
  ]
}