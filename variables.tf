variable "location" {
  type        = string
  description = "Regiao da cloud Azure para alocacao dos recursos"
  default     = "eastus2"
}

variable "environment" {
  type        = string
  description = "Ambiente de execucao dos recursos"
  default     = "lab"
}

variable "node_vm_size" {
  type        = string
  description = "SKU da maquina virtual do node pool homologada na regiao"
  default     = "Standard_B2s_v2"
}