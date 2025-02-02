terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 3.7.0"
    }
  }

  # Update this block with the location of your terraform state file
  backend "azurerm" {
    resource_group_name  = "tfstatedemo"
    storage_account_name = "tfgithubdemo"
    container_name       = "tfstate"
    key                  = "terraform.tfstate"
    use_oidc             = true
  }
}

provider "azurerm" {
  features {}
  use_oidc = true
}

# Create the resource group
resource "azurerm_resource_group" "rg" {
  name     = var.resource_group_name
  location = var.location
}

# Create the Linux App Service Plan
resource "azurerm_service_plan" "appserviceplan" {
  name                = "webapp-asp-${var.prefix_environment}"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  os_type             = "Linux"
  sku_name            = "B1"
}

# Create the web app, pass in the App Service Plan ID
resource "azurerm_linux_web_app" "webapp" {
  name                = "webapp-${var.prefix_environment}"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  service_plan_id     = azurerm_service_plan.appserviceplan.id
  https_only          = true
  site_config {
    minimum_tls_version = "1.2"
    application_stack {
      docker_registry_url = "https://docker.io"
      docker_image_name   = "nginx:latest"
    }
  }

}


# Create the Linux App Service Plan
resource "azurerm_service_plan" "appserviceplan2" {
  name                = "webapp-demo2-${var.prefix_environment}"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  os_type             = "Linux"
  sku_name            = "B2"
}

# Create the web app, pass in the App Service Plan ID
resource "azurerm_linux_web_app" "webapp2" {
  name                = "webapp-demo2-${var.prefix_environment}"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  service_plan_id     = azurerm_service_plan.appserviceplan2.id
  https_only          = true
  site_config {
    minimum_tls_version = "1.2"
    application_stack {
      docker_registry_url = "https://docker.io"
      docker_image_name   = "nginx:latest"
    }
  }

}

# Create Storage Account in Resource Group
resource "azurerm_storage_account" "attachmentstorage" {
  name                     = "attachmentstorage${lower(var.prefix_environment)}"
  resource_group_name      = azurerm_resource_group.rg.name
  location                 = azurerm_resource_group.rg.location
  account_tier             = "Standard"
  account_replication_type = "LRS"

  tags = {
    environment = var.prefix_environment
  }
}

resource "azurerm_storage_container" "attachmentcontainer" {
  name                  = "attachment"
  storage_account_name  = azurerm_storage_account.attachmentstorage.name
  container_access_type = "private"
}
