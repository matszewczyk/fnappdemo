provider "azurerm" {
  features {}
}

variable "envs" {
  type    = list(string)
  default = ["dev", "qa", "prod"]
}

resource "azurerm_resource_group" "rg" {
  count    = length(var.envs)
  name     = "fnappdemo-${var.envs[count.index]}"
  location = "North Europe"
}

resource "azurerm_storage_account" "sa" {
  count                    = length(var.envs)
  name                     = "fnappdemo${var.envs[count.index]}storageacc"
  resource_group_name      = azurerm_resource_group.rg[count.index].name
  location                 = azurerm_resource_group.rg[count.index].location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_service_plan" "example" {
  count               = length(var.envs)
  name                = "fnappdemo-${var.envs[count.index]}-app-service-plan"
  resource_group_name = azurerm_resource_group.rg[count.index].name
  location            = azurerm_resource_group.rg[count.index].location
  os_type             = "Linux"
  sku_name            = "Y1"
}

resource "azurerm_linux_function_app" "example" {
  count               = length(var.envs)
  name                = "fnappdemo-${var.envs[count.index]}"
  resource_group_name = azurerm_resource_group.rg[count.index].name
  location            = azurerm_resource_group.rg[count.index].location

  storage_account_name       = azurerm_storage_account.sa[count.index].name
  storage_account_access_key = azurerm_storage_account.sa[count.index].primary_access_key
  service_plan_id            = azurerm_service_plan.example[count.index].id

  site_config {}
}