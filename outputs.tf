output "resource_group_name" {
  value       = azurerm_resource_group.rg.name
  description = "Nome do Resource Group criado"
}

output "aks_cluster_name" {
  value       = azurerm_kubernetes_cluster.aks.name
  description = "Nome do cluster AKS provisionado"
}

output "get_credentials_command" {
  value       = "az aks get-credentials --resource-group ${azurerm_resource_group.rg.name} --name ${azurerm_kubernetes_cluster.aks.name} --overwrite-existing"
  description = "Comando para descarregar o kubeconfig para o kubectl local"
}