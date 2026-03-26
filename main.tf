terraform {
  required_version = ">= 1.4.0"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.0"
    }
    local = {
      source  = "hashicorp/local"
      version = "~> 2.0"
    }
    null = {
      source  = "hashicorp/null"
      version = "~> 3.0"
    }
  }
}

provider "azurerm" {
  features {}
  resource_provider_registrations = "none"
  subscription_id                 = "c064671c-8f74-4fec-b088-b53c568245eb"
}

data "azurerm_resource_group" "rg" {
  name = "s1202501"

}

module "network" {
  source              = "./modules/network"
  prefix              = var.prefix
  location            = data.azurerm_resource_group.rg.location
  resource_group_name = data.azurerm_resource_group.rg.name
}

module "vm" {
  source              = "./modules/vm"
  prefix              = var.prefix
  location            = data.azurerm_resource_group.rg.location
  resource_group_name = data.azurerm_resource_group.rg.name
  subnet_id           = module.network.subnet_gameserver_id
  ssh_public_key_path = var.ssh_public_key_path
}

module "acr" {
  source              = "./modules/acr"
  prefix              = var.prefix
  location            = data.azurerm_resource_group.rg.location
  resource_group_name = data.azurerm_resource_group.rg.name
}

module "aci" {
  source              = "./modules/aci"
  prefix              = var.prefix
  location            = data.azurerm_resource_group.rg.location
  resource_group_name = data.azurerm_resource_group.rg.name
  acr_login_server    = module.acr.login_server
  acr_username        = module.acr.admin_username
  acr_password        = module.acr.admin_password
  depends_on = [module.acr]
}