provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
}

# provider "helm" {
#   kubernetes {
#     host                   = azurerm_kubernetes_cluster.this.kube_admin_config.0.host
#     client_certificate     = base64decode(azurerm_kubernetes_cluster.this.kube_admin_config.0.client_certificate)
#     client_key             = base64decode(azurerm_kubernetes_cluster.this.kube_admin_config.0.client_key)
#     cluster_ca_certificate = base64decode(azurerm_kubernetes_cluster.this.kube_admin_config.0.cluster_ca_certificate)
#   }
# }

# provider "kubernetes" {
#   host                   = azurerm_kubernetes_cluster.this.kube_admin_config.0.host
#   client_certificate     = base64decode(azurerm_kubernetes_cluster.this.kube_admin_config.0.client_certificate)
#   client_key             = base64decode(azurerm_kubernetes_cluster.this.kube_admin_config.0.client_key)
#   cluster_ca_certificate = base64decode(azurerm_kubernetes_cluster.this.kube_admin_config.0.cluster_ca_certificate)
# }
