
data "azurerm_resource_group" "example" {
  name = "existing"
}

resource "azurerm_storage_account" "example" {
  name                     = "examplestorageacct"
  resource_group_name      = data.azurerm_resource_group.example.name
  location                 = data.azurerm_resource_group.example.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_storage_container" "example" {
  name                  = "tfstate"
  storage_account_name  = azurerm_storage_account.example.name
  container_access_type = "private"
}


//resource "azurerm_resource_group" "example" {
 // name     = data.azurerm_resource_group.example.name
  //location = var.location
//}

resource "azurerm_app_service_plan" "example" {
  name                = "example-appserviceplan"
  location            = data.azurerm_resource_group.example.location
  resource_group_name = data.azurerm_resource_group.example.name
  sku {
    tier     = "Standard"
    size     = "S1"
  }
}

resource "azurerm_app_service" "example" {
  name                = "example-appservice"
  location            = data.azurerm_resource_group.example.location
  resource_group_name = data.azurerm_resource_group.example.name
  app_service_plan_id = azurerm_app_service_plan.example.id

  app_settings = {
    "APPINSIGHTS_INSTRUMENTATIONKEY" = azurerm_application_insights.example.instrumentation_key
    "APPLICATIONINSIGHTS_CONNECTION_STRING" = azurerm_application_insights.example.connection_string
  }

  site_config {
    always_on = true
  }
}

resource "azurerm_application_insights" "example" {
  name                = "example-appinsights"
  location            = data.azurerm_resource_group.example.location
  resource_group_name = data.azurerm_resource_group.example.name
  application_type    = "web"
}

resource "azurerm_monitor_metric_alert" "example" {
  name                = "example-metric-alert"
  resource_group_name = data.azurerm_resource_group.example.name
  location            = data.azurerm_resource_group.example.location
  scopes              = [azurerm_app_service.example.id]
  description         = "An example metric alert"
  severity            = 3
  enabled             = true
  frequency           = "PT1M"
  window_size         = "PT5M"

  criteria {
    metric_namespace = "Microsoft.Web/sites"
    metric_name      = "Http5xx"
    aggregation      = "Total"
    operator         = "GreaterThan"
    threshold        = 1
  }

  action {
    action_group_id = azurerm_monitor_action_group.example.id
  }
}

resource "azurerm_monitor_action_group" "example" {
  name                = "example-actiongroup"
  resource_group_name = data.azurerm_resource_group.example.name
  short_name          = "example"

  email_receiver {
    name          = "sendtoexample"
    email_address = "example@example.com"
  }
}

output "storage_account_name" {
  value = azurerm_storage_account.example.name
}

//output "resource_group_name" {
  //value = azurerm_resource_group.example.name
//}
