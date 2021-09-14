**The VPN gateway part is not yet functional**

## Assumptions
* You have a default subscription set on the CLI
    * `az account list`
    * `az account set --subscription <subscription-id>`

## Scripts
| Script | Purpose |
| ------ | ------- |
| 0-install-tools.sh      | install AWS CLI and jq |
| 1-login-az.sh           | renew azure cli credentials if expired |
| 2-create-resources.sh   | create a resource group if it does not exist |
| 3-create-vnet.sh        | Creates a vnet, subnets using ARM templates |
| 4-create-storage.sh     | Creates bastion and vnet gateway using ARM templates |
| 5-create-vm.sh          | Create a simple virtual machine on the default subnet with no public IP | 
| 6-create-bastion.sh     | Creates a bastion host |
| 7-create-vpn.sh         | _future_ Creates a vpn appliance - certs managed in different script |
| 8-create-p2s.sh         | _future_ will create point to site vpn gateway |
| | |
| 92-purge-vnet.sh             | Remove everything other than the VNET and it's subnets | 
| 91-purge-resource-group.sh   | Remove everything in resource group using  an empty ARM template - leaves the resource group |
| 90-destroy-resource-group.sh | Remove a resource group. May only works if public ips are disassociated or deleted |


The ARM templates are applied in `Incremental` mode so they can be used to update a configuration.
The purge scripts apply an ARM template in `Complete` mode.

## Selecting Network Ranges
Pick network blocks that do not conflict with other networking.

1. Your VNET network
1. The Virtual Network Gateway address range

```
24-bit block	10.0.0.0 – 10.255.255.255	    16777216	10.0.0.0/8 (255.0.0.0)	      24 bits	8 bits	single class A network
20-bit block	172.16.0.0 – 172.31.255.255	    1048576	    172.16.0.0/12 (255.240.0.0)	  20 bits	12 bits	16 contiguous class B networks
16-bit block	192.168.0.0 – 192.168.255.255	65536	    192.168.0.0/16 (255.255.0.0)  16 bits	16 bits	256 contiguous class C networks
```

## Accessing Storage Containers via Portal
The portal will **forbid you from browsing your Storage Containers** unless you add your home machine IP to the firewall approve list
1. Drill into your _storage account_ inthe portal
1. Click on `Networking`
1. Look at `Firewalls and virtual networks`
1. Click the checkbox next to _Add your client IP address_
1. Click on `Save`
1. Verify your ip is in the address range list

## References

* https://en.wikipedia.org/wiki/Private_network
* https://arminreiter.com/2017/06/connect-windows-10-clients-azure-vpn/
* https://www.starwindsoftware.com/blog/configuring-azure-point-to-site-vpn-with-windows-10
* https://4sysops.com/archives/defining-a-public-ip-for-an-azure-resource-group-with-a-json-template/

Microsoft VNET
* https://docs.microsoft.com/en-us/azure/virtual-network/quick-create-cli

Microsoft - VPN gateway
* https://docs.microsoft.com/en-us/azure/vpn-gateway/vpn-gateway-about-vpngateways

Microsoft - ARM Templates
* https://docs.microsoft.com/en-us/azure/azure-resource-manager/templates/quickstart-create-templates-use-visual-studio-code?tabs=CLI
* https://docs.microsoft.com/en-us/azure/templates/microsoft.storage/storageaccounts/blobservices/containers?tabs=bicep
* https://github.com/Azure/azure-quickstart-templates/tree/master/quickstarts

Microsoft - Public IP
* https://docs.microsoft.com/en-us/azure/virtual-network/virtual-network-public-ip-address
* https://docs.microsoft.com/en-us/azure/virtual-network/public-ip-addresses

Microsoft - Bastion Hosts
* https://docs.microsoft.com/en-us/azure/bastion/tutorial-create-host-portal

Microsoft - P2S
* https://docs.microsoft.com/en-us/azure/storage/files/storage-files-configure-p2s-vpn-linux