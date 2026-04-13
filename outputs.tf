output "app_urls" {
  description = "URLs from Deployment on Azure"
  value = {
    for key, app in azurerm_linux_web_app.apps :
    key => "https://${app.default_hostname}"
  }
}

output "resource_group_name" {
  description = "Name of Resource Group"
  value       = azurerm_resource_group.this.name
}

output "service_plan_name" {
  description = "App Service Plan Name"
  value       = azurerm_service_plan.this.name
}
