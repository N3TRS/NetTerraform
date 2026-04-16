resource "azurerm_resource_group" "this" {
  name     = "rg-${var.project_name}-prod"
  location = var.location
}


resource "azurerm_service_plan" "this" {
  name                = "asp-${var.project_name}"
  resource_group_name = azurerm_resource_group.this.name
  location            = azurerm_resource_group.this.location
  os_type             = "Linux"
  sku_name            = var.sku_name
  worker_count        = var.instance_count
}

resource "azurerm_linux_web_app" "apps" {
  for_each = var.apps_config

  name                = "${var.project_name}-${each.key}"
  resource_group_name = azurerm_resource_group.this.name
  location            = azurerm_resource_group.this.location
  service_plan_id     = azurerm_service_plan.this.id

  site_config {
    always_on = true
    dynamic "application_stack" {
      for_each = each.value.type == "node" ? [1] : []
      content {
        node_version = each.value.version
      }
    }

    dynamic "application_stack" {
      for_each = each.value.type == "python" ? [1] : []
      content {
        python_version = each.value.python_version
      }
    }
  }

  app_settings = {
    "NODE_ENV" = "production"
  }

  lifecycle {
    ignore_changes = [app_settings, site_config[0].app_command_line]
  }

}



