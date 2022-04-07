#Create VPCs and VNETs for K8S spokes

#aws
module "aws_vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name                  = var.aws_network_name
  cidr                  = local.aws_avx_cidr
  secondary_cidr_blocks = [local.aws_eks_cidr]

  azs            = local.aws_availability_zones
  public_subnets = local.aws_public_subnets

  enable_nat_gateway = false
  enable_vpn_gateway = false

  tags = {
    Environment = "k8s"
  }
}

# resource "azurerm_network_security_group" "aks_nsg" {
#   name                = "aks-nsg"
#   location            = local.azurerm_azure_region
#   resource_group_name = var.azure_rg_name
# }

# resource "azurerm_network_security_rule" "rfc1918" {
#   name                        = "rfc1918"
#   priority                    = 100
#   direction                   = "Inbound"
#   access                      = "Allow"
#   protocol                    = "*"
#   source_port_range           = "*"
#   destination_port_range      = "*"
#   source_address_prefixes     = ["10.0.0.0/8"]
#   destination_address_prefix  = "VirtualNetwork"
#   network_security_group_name = azurerm_network_security_group.aks_nsg.name
#   resource_group_name         = azurerm_network_security_group.aks_nsg.resource_group_name
# }

#azure
module "azure_vnet" {
  source = "Azure/vnet/azurerm"

  vnet_name           = var.azure_network_name
  resource_group_name = azurerm_resource_group.aks.name
  address_space       = local.azure_vnet_cidrs
  subnet_prefixes     = local.azure_vnet_cidrs
  subnet_names        = ["avx", "aks"]

  nsg_ids = {
    #aks = azurerm_network_security_group.aks_nsg.id
  }

  route_tables_ids  = {}
  subnet_delegation = {}

  tags = {
    environment = "k8s"
  }

  depends_on = [
    azurerm_resource_group.aks
  ]
}

#gcp
module "gcp_vpc" {
  source  = "terraform-google-modules/network/google"
  version = "~> 4.0"

  project_id   = local.gcp_project_id
  network_name = var.gcp_network_name
  routing_mode = "GLOBAL"

  subnets = [
    {
      subnet_name   = "avx"
      subnet_ip     = local.gcp_avx_cidr
      subnet_region = var.gcp_region
    },
    {
      subnet_name   = "gke"
      subnet_ip     = local.gcp_gke_primary_cidr
      subnet_region = var.gcp_region
    }
  ]

  secondary_ranges = {
    gke = [
      {
        range_name    = "service"
        ip_cidr_range = local.gcp_gke_service_cidr
      },
      {
        range_name    = "pod"
        ip_cidr_range = local.gcp_gke_pod_cidr
      }
    ]
  }

  routes = [
    {
      name              = "egress-internet"
      description       = "route through IGW to access internet"
      destination_range = "0.0.0.0/0"
      tags              = "egress-inet"
      next_hop_internet = "true"
    }
  ]

  firewall_rules = [
    {
      name      = "rfc1918-gke"
      direction = "INGRESS"
      ranges    = ["10.0.0.0/8"]
      allow = [{
        protocol = "all"
        ports    = []
      }]
    }
  ]
}