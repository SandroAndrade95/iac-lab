terraform {
  backend "azurerm" {
    #use_microsoft_graph  = true
    tenant_id            = "c065ccde-3740-4fff-b444-fc79a3452801"
    subscription_id      = "5c32571a-bb02-413d-9349-fa99ce5ba596"
    resource_group_name  = "rg-mgmt"
    storage_account_name = "sasandrolabtfstate"
    container_name       = "tfstate"
    key                  = "dev.tfstate"
  }
}