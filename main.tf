# We strongly recommend using the required_providers block to set the
# Azure Provider source and version being used
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "=3.110.0"
    }
  }
}

# Configure the Microsoft Azure Provider
provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
}

resource "azurerm_resource_group" "rg" {
  name     = var.resource_group_name
  location = var.location

  tags = {
    environment = var.environment
    source      = "terraform"
    owner       = var.owner
  }
}

resource "azurerm_storage_account" "func_storage" {
  name                     = var.storage_account_name
  resource_group_name      = azurerm_resource_group.rg.name
  location                 = azurerm_resource_group.rg.location
  account_tier             = "Standard"
  account_replication_type = "LRS"

  tags = {
    environment = var.environment
    source      = "terraform"
    owner       = var.owner
  }
}

resource "azurerm_storage_queue" "storage_queue" {
  name                 = "copyblobqueue"
  storage_account_name = azurerm_storage_account.func_storage.name
}

resource "azurerm_storage_queue" "json_process_queue" {
  name                 = "jsonprocessqueue"
  storage_account_name = azurerm_storage_account.func_storage.name
}

resource "azurerm_storage_container" "storage_container" {
  name                 = "helloworld"
  storage_account_name = azurerm_storage_account.func_storage.name
}

resource "azurerm_storage_container" "json_messages_container" {
  name                 = "json-messages"
  storage_account_name = azurerm_storage_account.func_storage.name
  container_access_type = "private"
}

resource "azurerm_service_plan" "func_consumption_plan" {
  name                = "cloudengineerskillstfconsumptionplan"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  os_type             = "Linux"
  sku_name            = "Y1"

  tags = {
    environment = var.environment
    source      = "terraform"
    owner       = var.owner
  }
}

resource "azurerm_log_analytics_workspace" "logs" {
  name                = "workspace-test"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  sku                 = "PerGB2018"
  retention_in_days   = 30

  tags = {
    environment = var.environment
    source      = "terraform"
    owner       = var.owner
  }
}

resource "azurerm_application_insights" "insights" {
  name                = "tf-test-appinsights"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  workspace_id        = azurerm_log_analytics_workspace.logs.id
  application_type    = "Node.JS"

  tags = {
    environment = var.environment
    source      = "terraform"
    owner       = var.owner
  }
}

# Create zip file for function deployment
data "archive_file" "function_app_zip" {
  type        = "zip"
  source_dir  = "${path.module}"
  output_path = "${path.module}/function-app.zip"
  excludes = [
    "*.tf",
    "*.tfvars", 
    "*.tfstate*",
    ".terraform*",
    "*.md",
    "*.ps1",
    "*.zip",
    ".git*",
    "src/"
  ]
}

resource "azurerm_linux_function_app" "func_app" {
  name                       = var.function_app_name
  resource_group_name        = azurerm_resource_group.rg.name
  location                   = azurerm_resource_group.rg.location
  storage_account_name       = azurerm_storage_account.func_storage.name
  storage_account_access_key = azurerm_storage_account.func_storage.primary_access_key
  service_plan_id            = azurerm_service_plan.func_consumption_plan.id

  site_config {
    application_stack {
      python_version = "3.11"
    }

    application_insights_connection_string = azurerm_application_insights.insights.connection_string
    application_insights_key               = azurerm_application_insights.insights.instrumentation_key
  }

  app_settings = {
    "STORAGE_ACCOUNT_CONNECTION_STRING"     = azurerm_storage_account.func_storage.primary_connection_string
    "WEBSITE_RUN_FROM_PACKAGE"              = "1"
    "FUNCTIONS_WORKER_RUNTIME"              = "python"
    "FUNCTIONS_EXTENSION_VERSION"           = "~4"
  }

  zip_deploy_file = data.archive_file.function_app_zip.output_path

  tags = {
    environment = var.environment
    source      = "terraform"
    owner       = var.owner
  }
}
