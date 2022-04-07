#Providers config

terraform {
  required_providers {
    aviatrix = {
      source = "aviatrixsystems/aviatrix"
      #version = "2.19.5"
    }
    aws = {
      source = "hashicorp/aws"
    }
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "=3.0.2"
    }
    google = {
      source = "hashicorp/google"
    }
  }
}

provider "aviatrix" {}

provider "aws" {
  region = var.aws_region
}

provider "azurerm" {
  features {}
  subscription_id = local.azure_subscription_id
}

provider "google" {}