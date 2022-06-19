variable "tenant" {
  type        = string
  description = "Name of Tenant in Netbox"
  default     = ""
}

variable "cluster" {
  type        = string
  description = "Name of VM cluster in Netbox"
}

variable "name" {
  type        = string
  description = "Name of the virtual machine"
}

variable "tags" {
  type        = list(string)
  description = "Tags to apply to all resources created by Terraform"
  default     = []
}

variable "vm_tags" {
  type        = list(string)
  description = "Additional tags to apply to the VM"
  default     = []
}

variable "vcpus" {
  type        = number
  description = "The number of VCPUS for this VM"
  default     = null
}

variable "memory" {
  type        = number
  description = "The size in MB of the memory of this VM"
  default     = null
}

variable "disk" {
  type        = number
  description = "The size in GB of the disk for this VM"
  default     = null
}

variable "comments" {
  type        = string
  description = "Comments for the VM"
  default     = null
}

variable "platform" {
  type        = string
  description = "Name of platform in Netbox"
  default     = ""
}

variable "services" {
  description = "Services on the VM"
  default     = []
}

variable "interfaces" {
  description = "Interfaces on the VM"
  default     = []
}
