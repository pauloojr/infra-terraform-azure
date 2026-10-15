# Obtem dinamicamente a versao estavel recomendada de Kubernetes para a regiao
data "azurerm_kubernetes_service_versions" "current" {
  location        = var.location
  include_preview = false
}

resource "azurerm_resource_group" "rg" {
  name     = "rg-${var.environment}-aks"
  location = var.location

  tags = {
    Environment = var.environment
    ManagedBy   = "Terraform"
  }
}

resource "azurerm_virtual_network" "vnet" {
  name                = "vnet-${var.environment}-aks"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  address_space       = ["10.0.0.0/16"]

  tags = {
    Environment = var.environment
    ManagedBy   = "Terraform"
  }
}

resource "azurerm_subnet" "aks_subnet" {
  name                 = "snet-aks"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.0.1.0/24"]
}

resource "azurerm_kubernetes_cluster" "aks" {
  name                = "aks-${var.environment}-cluster"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  dns_prefix          = "aks-${var.environment}"
  # Utiliza a versao mais recente estavel de producao disponivel na regiao
  kubernetes_version  = data.azurerm_kubernetes_service_versions.current.latest_version

  default_node_pool {
    name            = "system"
    node_count      = 1
    vm_size         = var.node_vm_size
    vnet_subnet_id  = azurerm_subnet.aks_subnet.id
    os_disk_size_gb = 30
  }

  identity {
    type = "SystemAssigned"
  }

  network_profile {
    network_plugin    = "kubenet"
    load_balancer_sku = "standard"
  }

  tags = {
    Environment = var.environment
    ManagedBy   = "Terraform"
  }
}

resource "azurerm_kubernetes_cluster_node_pool" "spot" {
  name                  = "spotpool"
  kubernetes_cluster_id = azurerm_kubernetes_cluster.aks.id
  vm_size               = var.node_vm_size
  node_count            = 1
  vnet_subnet_id        = azurerm_subnet.aks_subnet.id
  os_disk_size_gb       = 30

  priority        = "Spot"
  eviction_policy = "Delete"
  spot_max_price  = -1

  node_labels = {
    "kubernetes.azure.com/scalesetpriority" = "spot"
    "workload"                              = "stateless"
  }

  node_taints = [
    "kubernetes.azure.com/scalesetpriority=spot:NoSchedule"
  ]

  tags = {
    Environment = var.environment
    ManagedBy   = "Terraform"
  }
}