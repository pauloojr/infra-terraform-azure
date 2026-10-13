variable "location" {
  type        = string
  description = "Regiao da cloud para alocacao dos recursos"
  default     = "eastus2"
}

variable "environment" {
  type        = string
  description = "Ambiente de execucao"
  default     = "lab"
}

variable "node_vm_size" {
  type        = string
  description = "SKU da maquina virtual do node pool"
  default     = "Standard_B2s"
}