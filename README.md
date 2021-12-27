**The VPN gateway part is not yet functional**
## Purpose
Create a working Azure environment with
* Network with VNET
* Several Subnets
* Application Insights instancess with Log Analytics Workspace
* Storage Accounts with storage containers
* Linus VM with Log Analytics Workspace and Application Insights binding and agent
* RDP bastion server
* VPN endpoint

## Assumptions
* You have a default subscription set on the CLI
    * `az account list`
    * `az account set --subscription <subscription-id>`

## Scripts
| Script                       | Required for Bastion | Required for P2S VPN | Purpose |
| ---------------------------- | -------------------- | -------------------- | ------- |
| 0-install-tools.sh           | yes | yes | install AWS CLI and jq |
| 1-login-az.sh                | yes | yes | renew azure cli credentials if expired |
| 2-create-resources.sh        | yes | yes | create a resource group if it does not exist |
| 3-create-vnet.sh             | yes | yes | Creates a vnet, subnets |
| 4-create-storage.sh          | opt | opt | Creates storage accounts, storage containers and Private Link Endpoints |
| 5-create-monitor.sh          | opt | opt | Creates Log Analytics Workspace and Application Insights instance |
| 6-create-vm-linux.sh         | yes | opt | Create a simple virtual machine on the default subnet with no public IP with a log analytics workspace | 
| 7-create-bastion.sh          | yes | no  | Creates a bastion host |
| 8-create-vpn.sh              | no  | yes | _future_ Creates a vpn appliance - certs managed in different script |
| 9-create-p2s.sh              | no  | yes | _future_ will create point to site vpn gateway |
| | | | | 
| 92-purge-vnet.sh             | n/a | n/a | Remove everything other than the VNET and it's subnets | 
| 91-purge-resource-group.sh   | n/a | n/a | Remove everything in resource group using  an empty ARM template - leaves the resource group |
| 90-destroy-resource-group.sh | n/a | n/a | Remove a resource group. May only works if public ips are disassociated or deleted |


The ARM templates are applied in `Incremental` mode so they can be used to update a configuration.
The purge scripts apply an ARM template in `Complete` mode.

## Selecting Network Ranges
Pick network blocks that do not conflict with other networking. The network blocks below are non-routable (private) network blocks.

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

ARM Templates
* https://docs.microsoft.com/en-us/azure/azure-resource-manager/templates/quickstart-create-templates-use-visual-studio-code?tabs=CLI
* https://github.com/Azure/azure-quickstart-templates/tree/master/quickstarts
* https://docs.microsoft.com/en-us/azure/templates/microsoft.storage/storageaccounts/blobservices/containers?tabs=bicep
* https://docs.microsoft.com/en-us/azure/azure-resource-manager/templates/variables
* https://docs.microsoft.com/en-us/azure/azure-resource-manager/templates/outputs
* https://docs.microsoft.com/en-us/azure/azure-resource-manager/templates/template-expressions
* https://docs.microsoft.com/en-us/azure/virtual-machines/tag-template

VNET / Subnet / Network
* https://docs.microsoft.com/en-us/azure/virtual-network/quick-create-cli
* https://en.wikipedia.org/wiki/Private_network

Public IP
* https://docs.microsoft.com/en-us/azure/virtual-network/virtual-network-public-ip-address
* https://docs.microsoft.com/en-us/azure/virtual-network/public-ip-addresses
* https://4sysops.com/archives/defining-a-public-ip-for-an-azure-resource-group-with-a-json-template/

Bastion Hosts
* https://docs.microsoft.com/en-us/azure/bastion/tutorial-create-host-portal

VPN gateway
* https://docs.microsoft.com/en-us/azure/vpn-gateway/vpn-gateway-about-vpngateways
* https://arminreiter.com/2017/06/connect-windows-10-clients-azure-vpn/
* https://www.starwindsoftware.com/blog/configuring-azure-point-to-site-vpn-with-windows-10

P2S
* https://docs.microsoft.com/en-us/azure/storage/files/storage-files-configure-p2s-vpn-linux

VM Agents
* https://github.com/MicrosoftDocs/azure-docs/blob/master/articles/virtual-machines/extensions/oms-linux.md
* https://docs.microsoft.com/en-us/azure/virtual-machines/extensions/agent-dependency-linux
