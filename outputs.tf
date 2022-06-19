output "vm_id" {
  description = "Netbox ID for the VM resource"
  value       = netbox_virtual_machine.main.id
  sensitive   = false
}

output "interface_ids" {
  description = "Netbox ID for the interface resources"
  value       = length(var.interfaces) > 0 ? { for interface in netbox_interface.main : interface.name => interface.id } : {}
  sensitive   = false
}

output "ip_address_ids" {
  description = "Netbox ID for the interface resources"
  value       = length(local.ip_addresses) > 0 ? { for interface in netbox_ip_address.interface : interface.ip_address => interface.id } : {}
  sensitive   = false
}
