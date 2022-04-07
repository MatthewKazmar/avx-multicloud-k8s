#Regions - default puts everything in Ashburn
variable "aws_region" { default = "us-east-1" }
variable "azure_region" { default = "eastus" }
variable "gcp_region" { default = "us-east4" }

variable "azure_rg_name" { default = "aks" }

#Account names in the Aviatrix Controller
variable "aws_account_name" { type = string }
variable "azure_account_name" { type = string }
variable "gcp_account_name" { type = string }

#VPC names
variable "aws_network_name" { default = "eks-vpc" }
variable "azure_network_name" { default = "azure-vnet" }
variable "gcp_network_name" { default = "gcp-vpc" }

#Spoke VPC/VNET CIDRs, subnet logic assumes a /16 for each CSP
variable "aws_vpc_cidr" { default = "10.1.0.0/16" }
variable "azure_vnet_cidr" { default = "10.2.0.0/16" }
variable "gcp_vpc_cidr" { default = "10.3.0.0/16" }
variable "avx_transit_cidr" { default = "10.0.0.0/16" }

#Kubernetes details

variable "node_count" { default = 2 }
#Node size, 4x16
variable "aws_node_size" { default = "t3a.xlarge" }
variable "azure_node_size" { default = "Standard_B4ms" }
variable "gcp_node_size" { default = "e2-standard-4" }

locals {
  azure_subscription_id = data.aviatrix_account.azure.arm_subscription_id
  gcp_project_id        = data.aviatrix_account.gcp.gcloud_project_id

  azurerm_azure_region = module.azure_region.location_cli
  avx_azure_region     = module.azure_region.location

  avx_transit_cidr = cidrsubnet(var.avx_transit_cidr, 8, 0)

  aws_avx_cidr         = cidrsubnet(var.aws_vpc_cidr, 7, 0)
  aws_avx_cidr_primary = cidrsubnet(local.aws_avx_cidr, 1, 0)
  aws_avx_cidr_ha      = cidrsubnet(local.aws_avx_cidr, 1, 1)
  aws_eks_cidr         = cidrsubnet(var.aws_vpc_cidr, 1, 1)
  aws_public_subnets   = [local.aws_avx_cidr_primary, local.aws_avx_cidr_ha, cidrsubnet(local.aws_eks_cidr, 1, 0), cidrsubnet(local.aws_eks_cidr, 1, 1)]
  aws_service_cidr     = cidrsubnet(var.aws_vpc_cidr, 8, 2)

  azure_avx_cidr           = cidrsubnet(var.azure_vnet_cidr, 7, 0)
  azure_vnet_cidrs         = [local.azure_avx_cidr, cidrsubnet(var.azure_vnet_cidr, 1, 1)]
  azure_service_cidr       = cidrsubnet(var.azure_vnet_cidr, 8, 4)
  azure_docker_bridge_cidr = cidrsubnet(var.azure_vnet_cidr, 8, 3)

  gcp_avx_cidr         = cidrsubnet(var.gcp_vpc_cidr, 7, 0)
  gcp_gke_primary_cidr = cidrsubnet(var.gcp_vpc_cidr, 8, 2)
  gcp_gke_service_cidr = cidrsubnet(var.gcp_vpc_cidr, 8, 3)
  gcp_gke_pod_cidr     = cidrsubnet(var.gcp_vpc_cidr, 1, 1)

  #Grab the first 2 AZs - these map to the Public Subnets, so just 2 AZs applied to 4 subnets
  aws_availability_zones = [data.aws_availability_zones.available.names[0], data.aws_availability_zones.available.names[1], data.aws_availability_zones.available.names[0], data.aws_availability_zones.available.names[1]]
}