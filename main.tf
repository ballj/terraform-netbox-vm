terraform {
  required_version = ">= 0.13.0"
  required_providers {
    netbox = {
      source  = "e-breuninger/netbox"
      version = ">= 2.0.0"
    }
  }
}

locals {
  ip_addresses = flatten([for interface in var.interfaces : [for ip_address in interface.ip_addresses : {
    ip_address  = ip_address.ip_address,
    status      = lookup(ip_address, "status", "active")
    interface   = interface.name
    dns_name    = lookup(ip_address, "dns_name", null)
    vrf_id      = lookup(ip_address, "vrf_id", null)
    description = lookup(ip_address, "description", null)
    primary     = lookup(ip_address, "primary", false)
    is_ipv6     = lookup(ip_address, "ipv6", false)
    tags        = lookup(ip_address, "tags", [])
  }] if contains(keys(interface), "ip_addresses")])
  ip_address_map    = { for ip_address in local.ip_addresses : ip_address.ip_address => ip_address }
  primary_addresses = [for ip_address in local.ip_addresses : ip_address.ip_address if ip_address.primary]
}

data "netbox_cluster" "main" {
  count = length(var.cluster) > 0 ? 1 : 0
  name = var.cluster
}

data "netbox_tenant" "main" {
  count = length(var.tenant) > 0 ? 1 : 0
  name  = var.tenant
}

data "netbox_platform" "main" {
  count = length(var.platform) > 0 ? 1 : 0
  name  = var.platform
}

resource "netbox_virtual_machine" "main" {
  cluster_id   = length(var.cluster) > 0 ? data.netbox_cluster.main[0].id : null
  site_id      = var.site_id > 0 ? var.site_id : null
  tenant_id    = length(var.tenant) > 0 ? data.netbox_tenant.main[0].id : null
  platform_id  = length(var.platform) > 0 ? data.netbox_platform.main[0].id : null
  name         = var.name
  vcpus        = var.vcpus
  memory_mb    = var.memory
  disk_size_gb = var.disk
  tags         = flatten([var.tags, var.vm_tags])
  comments     = var.comments
}

resource "netbox_service" "main" {
  for_each           = { for service in var.services : service.name => service }
  name               = each.key
  ports              = each.value.ports
  protocol           = lower(each.value.protocol)
  virtual_machine_id = netbox_virtual_machine.main.id
}

resource "netbox_interface" "main" {
  for_each           = { for interface in var.interfaces : interface.name => interface }
  virtual_machine_id = netbox_virtual_machine.main.id
  name               = each.key
  description        = lookup(each.value, "description", null)
  enabled            = lookup(each.value, "enabled", true)
  mac_address        = lookup(each.value, "mac_address", null)
  mode               = lookup(each.value, "mode", "access")
  tagged_vlans       = lookup(each.value, "tagged_vlans", null)
  untagged_vlan      = lookup(each.value, "untagged_vlan", null)
  tags               = flatten([var.tags, lookup(each.value, "tags", [])])
}

resource "netbox_ip_address" "interface" {
  count        = length(local.ip_addresses)
  tenant_id    = length(var.tenant) > 0 ? data.netbox_tenant.main[0].id : null
  ip_address   = local.ip_addresses[count.index].ip_address
  interface_id = netbox_interface.main[local.ip_addresses[count.index].interface].id
  status       = local.ip_addresses[count.index].status
  dns_name     = local.ip_addresses[count.index].dns_name
  description  = local.ip_addresses[count.index].description
  vrf_id       = local.ip_addresses[count.index].vrf_id
  tags         = flatten([var.tags, local.ip_addresses[count.index].tags])
}

resource "netbox_primary_ip" "primary" {
  count              = length(local.primary_addresses) > 0 ? 1 : 0
  virtual_machine_id = netbox_virtual_machine.main.id
  ip_address_id      = lookup({ for interface in netbox_ip_address.interface.* : interface.ip_address => interface.id }, element(local.primary_addresses, 0))
  ip_address_version = length(split(":", element(local.primary_addresses, 0))) > 1 ? 6 : 4
  depends_on = [
    netbox_interface.main
  ]
}

resource "netbox_primary_ip" "secondary" {
  count              = length(local.primary_addresses) > 1 ? 1 : 0
  virtual_machine_id = netbox_virtual_machine.main.id
  ip_address_id      = lookup({ for interface in netbox_ip_address.interface.* : interface.ip_address => interface.id }, element(local.primary_addresses, 1))
  ip_address_version = length(split(":", element(local.primary_addresses, 1))) > 1 ? 6 : 4
  depends_on = [
    netbox_interface.main,
    netbox_primary_ip.primary
  ]
}
