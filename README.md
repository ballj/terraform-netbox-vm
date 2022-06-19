# Terraform Netbox VM

This terraform module adds a VM into Netbox.

## Usage

```
module "vm" {
  source  = "ballj/vm/netbox"
  version = "~> 1.0"
  cluster = "Cluster-1"
  name    = "VM"
}
```

## Variables

### Global Variables

| Variable              | Required | Default          | Description                              |
| --------------------- | -------- | ---------------- | ---------------------------------------- |
| `name`                | Yes      | `""`             | Name of the virtual machine              |
| `cluster`             | Yes      | N/A              | Name of VM cluster in Netbox             |
| `tags`                | No       | `[]`             | Tags to apply to all resources           |
| `vm_tags`             | No       | `[]`             | Additional tags to apply to the VM       |
| `vcpus`               | No       | `null`           | The number of VCPUS for this VM          |
| `memory`              | No       | `null`           | The size in MB of the memory of this VM  |
| `disk`                | No       | `null`           | The size in GB of the disk for this VM   |
| `comments`            | No       | `""`             | Comments for the VM                      |
| `platform`            | No       | `""`             | Name of platform in Netbox               |
| `services`            | No       | `[]`             | Services on the VM                       |
| `interfaces`          | No       | `[]`             | Interfaces on the VM                     |

### Service Variables

| Variable              | Required | Default          | Description                              |
| --------------------- | -------- | ---------------- | ---------------------------------------- |
| `name`                | Yes      | N/A              | Name of the virtual machine              |
| `ports`               | Yes      | N/A              | List of ports                            |
| `protocol`            | Yes      | N/A              | Protocol, `tcp`/`udp`/`sctp`             |

## Interface Variables

| Variable              | Required | Default          | Description                              |
| --------------------- | -------- | ---------------- | ---------------------------------------- |
| `name`                | Yes      | N/A              | Name of the interface                    |
| `description`         | No       | `null`           | Description of the interface             |
| `enabled`             | No       | `true`           | If interface is enabled                  |
| `mac_address`         | No       | `null`           | MAC address of interface                 |
| `mode`                | No       | `null`           | Mode: `access`/`tagged`/`tagged-all`     |
| `tagged_vlans`        | No       | `null`           | List of vlans                            |
| `untagged_vlan`       | No       | `null`           | Untagged vlan                            |
| `tags`                | No       | `[]`             | Extra tags to apply to the interface     |

## IP Address Variables

| Variable              | Required | Default          | Description                              |
| --------------------- | -------- | ---------------- | ---------------------------------------- |
| `ip_address`          | Yes      | N/A              | IP Address                               |
| `status`              | No       | `null`           | IP status                                |
| `dns_name`            | No       | `true`           | DNS Name for the IP                      |
| `description`         | No       | `null`           | IP address description                   |
| `primary`             | No       | `false`          | If the IP is the primary for the VM      |
| `tags`                | No       | `[]`             | Extra tags to apply to the interface     |

## Examples

Module using most options:

```
module "vm_" {
  source              = "ballj/vm/netbox"
  tenant   = "Cyark"
  cluster  = "Cluster-1"
  name     = "VM5"
  tags     = ["managed-by-terraform", "spare"]
  vm_tags  = ["vm"]
  platform = "Oracle Cloud"
  interfaces = [
    {
      name = "enp0s3"
      tags = ["interface"]
      description = "Primary Interface"
      ip_addresses = [
        {
          ip_address = "10.0.0.10/24"
          dns_name = "test.example.com"
          tags = ["private"]
          primary = true
        },
        {
          ip_address = "2603:1111:1/64"
          dns_name = "test1.example.com"
          tags = ["private"]
          primary = true
        },
        {
          ip_address = "2603:1111:2/64"
          dns_name = "test2.example.com"
          tags = ["private"]
        }
      ]
    }
  ]
}
```
