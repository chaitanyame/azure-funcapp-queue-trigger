output "resource_group_name" {
  description = "Name of the resource group"
  value       = azurerm_resource_group.rg.name
}

output "storage_account_name" {
  description = "Name of the storage account"
  value       = azurerm_storage_account.func_storage.name
}

output "storage_connection_string" {
  description = "Storage account connection string"
  value       = azurerm_storage_account.func_storage.primary_connection_string
  sensitive   = true
}

output "function_app_name" {
  description = "Name of the function app"
  value       = azurerm_linux_function_app.func_app.name
}

output "function_app_url" {
  description = "URL of the function app"
  value       = "https://${azurerm_linux_function_app.func_app.name}.azurewebsites.net"
}

output "application_insights_instrumentation_key" {
  description = "Application Insights instrumentation key"
  value       = azurerm_application_insights.insights.instrumentation_key
  sensitive   = true
}

output "queue_name" {
  description = "Name of the storage queue"
  value       = azurerm_storage_queue.storage_queue.name
}

output "container_name" {
  description = "Name of the storage container"
  value       = azurerm_storage_container.storage_container.name
}
