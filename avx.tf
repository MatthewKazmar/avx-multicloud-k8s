# Deploy Aviatrix transit, spokes, and connect it all.

module "aws_transit" {
  source  = "terraform-aviatrix-modules/mc-transit/aviatrix"
  version = "2.0.0"

  cloud   = "aws"
  region  = var.aws_region
  cidr    = var.avx_transit_cidr
  account = var.aws_account_name
}

module "aws_spoke" {
  source  = "terraform-aviatrix-modules/mc-spoke/aviatrix"
  version = "1.1.2"

  cloud            = "aws"
  name             = "eks"
  region           = var.aws_region
  account          = var.aws_account_name
  transit_gw       = module.aws_transit.transit_gateway.gw_name
  use_existing_vpc = true
  ha_gw            = true
  vpc_id           = module.aws_vpc.vpc_id
  gw_subnet        = local.aws_avx_cidr_primary
  hagw_subnet      = local.aws_avx_cidr_ha

  depends_on = [
    module.aws_vpc
  ]
}

module "azure_spoke" {
  source  = "terraform-aviatrix-modules/mc-spoke/aviatrix"
  version = "1.1.2"

  cloud            = "azure"
  name             = "aks"
  region           = local.avx_azure_region
  account          = var.azure_account_name
  transit_gw       = module.aws_transit.transit_gateway.gw_name
  use_existing_vpc = true
  ha_gw            = true
  vpc_id           = "${module.azure_vnet.vnet_name}:${var.azure_rg_name}"
  gw_subnet        = local.azure_avx_cidr
  hagw_subnet      = local.azure_avx_cidr
  az_support       = true

  depends_on = [
    module.azure_vnet
  ]
}

module "gcp_spoke" {
  source  = "terraform-aviatrix-modules/mc-spoke/aviatrix"
  version = "1.1.2"

  cloud                            = "gcp"
  name                             = "gke"
  region                           = var.gcp_region
  account                          = var.gcp_account_name
  transit_gw                       = module.aws_transit.transit_gateway.gw_name
  use_existing_vpc                 = true
  ha_gw                            = true
  vpc_id                           = module.gcp_vpc.network_name
  gw_subnet                        = local.gcp_avx_cidr
  hagw_subnet                      = local.gcp_avx_cidr
  included_advertised_spoke_routes = var.gcp_vpc_cidr

  depends_on = [
    module.gcp_vpc
  ]
}