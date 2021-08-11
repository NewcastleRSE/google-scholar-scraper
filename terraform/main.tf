terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "=2.71.0"
    }
  }
}

provider "azurerm" {
  subscription_id   = "e7cbfebb-f482-46c4-a90b-126855b03325"
  features {
  }
}
resource "azurerm_resource_group" "googlescholar" {
  name     = "GoogleScholar"
  location = "UK South"

  tags = {
    name          = var.googlescholar-name
    pi            = var.googlescholar-pi
    contributors  = var.googlescholar-contributors
  }
}

resource "azurerm_container_registry" "googlescholarregistry" {
  name                = "googlescholarregistry"
  resource_group_name = azurerm_resource_group.googlescholar.name
  location            = azurerm_resource_group.googlescholar.location
  sku                 = "Standard"
  admin_enabled       = true
}

resource "azurerm_storage_account" "googlescholar-storage" {
  name                     = "googlescholar"
  resource_group_name      = azurerm_resource_group.googlescholar.name
  location                 = azurerm_resource_group.googlescholar.location
  account_tier             = "Standard"
  account_replication_type = "LRS"

  tags = {
    name          = var.googlescholar-name
    pi            = var.googlescholar-pi
    contributors  = var.googlescholar-contributors
  }
}

resource "azurerm_app_service_plan" "googlescholar-serviceplan" {
  name                = "googlescholar"
  location            = azurerm_resource_group.googlescholar.location
  resource_group_name = azurerm_resource_group.googlescholar.name
  kind                = "FunctionApp"

  sku {
    tier = "Dynamic"
    size = "Y1"
  }

  tags = {
    name          = var.googlescholar-name
    pi            = var.googlescholar-pi
    contributors  = var.googlescholar-contributors
  }
}

resource "azurerm_function_app" "googlescholarapp" {
  name                       = "publicationsbyauthor"
  location                   = azurerm_resource_group.googlescholar.location
  resource_group_name        = azurerm_resource_group.googlescholar.name
  app_service_plan_id        = azurerm_app_service_plan.googlescholar-serviceplan.id
  storage_account_name       = azurerm_storage_account.googlescholar-storage.name
  storage_account_access_key = azurerm_storage_account.googlescholar-storage.primary_access_key
  os_type                    = "linux"

  tags = {
    name          = var.googlescholar-name
    pi            = var.googlescholar-pi
    contributors  = var.googlescholar-contributors
  }
}
