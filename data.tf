# Data from the providers

data "aviatrix_account" "gcp" {
  account_name = var.gcp_account_name
}

data "aviatrix_account" "azure" {
  account_name = var.azure_account_name
}

data "aws_availability_zones" "available" {
  state = "available"
}

# data "google_compute_zones" "available" {
#   project = local.gcp_project_id
#   region  = var.gcp_region
# }