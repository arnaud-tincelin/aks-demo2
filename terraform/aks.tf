resource "azuread_group" "aks_admin" {
  display_name     = "ati-aks-demo-admin"
  security_enabled = true

  owners = [
    data.azurerm_client_config.current.object_id,
  ]

  members = [
    data.azurerm_client_config.current.object_id,
  ]
}

data "azurerm_client_config" "current" {}

resource "azurerm_kubernetes_cluster" "this" {
  name                      = "aks-demo"
  location                  = azurerm_resource_group.this.location
  resource_group_name       = azurerm_resource_group.this.name
  dns_prefix                = "aks-demo"
  oidc_issuer_enabled       = true
  workload_identity_enabled = true

  default_node_pool {
    name                         = "system"
    node_count                   = 1
    vm_size                      = "Standard_DS2_v2"
    vnet_subnet_id               = azurerm_subnet.nodes.id
    min_count                    = 1
    max_count                    = 5
    enable_auto_scaling          = true
    os_sku                       = "AzureLinux"
    only_critical_addons_enabled = true
    temporary_name_for_rotation  = "systemtmp"
  }

  identity {
    type = "SystemAssigned"
  }

  network_profile {
    network_plugin = "azure"
    network_policy = "azure"
  }

  ingress_application_gateway {
    gateway_name = "aks-demo"
    subnet_id    = azurerm_subnet.gateway.id
  }

  key_vault_secrets_provider {
    secret_rotation_enabled = true
  }

  azure_active_directory_role_based_access_control {
    managed                = true
    admin_group_object_ids = [azuread_group.aks_admin.id]
    azure_rbac_enabled     = true
  }
}

resource "azurerm_kubernetes_cluster_node_pool" "default" {
  name                  = "default"
  kubernetes_cluster_id = azurerm_kubernetes_cluster.this.id
  vm_size               = "Standard_DS2_v2"
  node_count            = 1
  enable_auto_scaling   = true
  os_type               = "Linux"
  os_sku                = "AzureLinux"
  vnet_subnet_id        = azurerm_subnet.nodes.id
  max_pods              = 50
  min_count             = 1
  max_count             = 5
  mode                  = "User"
}

resource "azurerm_role_assignment" "aks_acrpull" {
  principal_id         = azurerm_kubernetes_cluster.this.kubelet_identity[0].object_id
  role_definition_name = "AcrPull"
  scope                = azurerm_container_registry.this.id
}

resource "azurerm_role_assignment" "aks_networkcontributor" {
  principal_id         = azurerm_kubernetes_cluster.this.ingress_application_gateway[0].ingress_application_gateway_identity[0].object_id
  role_definition_name = "Network Contributor"
  scope                = azurerm_subnet.gateway.id
}

resource "local_file" "kubeconfig" {
  content  = azurerm_kubernetes_cluster.this.kube_admin_config_raw
  filename = "${path.module}/kubeconfig"
}
