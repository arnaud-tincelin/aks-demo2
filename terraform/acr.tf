resource "azurerm_container_registry" "this" {
  name                = "atiaksdemo"
  location            = azurerm_resource_group.this.location
  resource_group_name = azurerm_resource_group.this.name
  sku                 = "Basic"
}

resource "terraform_data" "acr_build_weatherforecast" {
  triggers_replace = tomap({
    "registry" = azurerm_container_registry.this.name
  })

  provisioner "local-exec" {
    command     = "az acr build --registry ${self.triggers_replace["registry"]} --image weatherforecast/api:latest --platform linux ."
    working_dir = abspath("${path.module}/../weatherforecast")
  }
}
