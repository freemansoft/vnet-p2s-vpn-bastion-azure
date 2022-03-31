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
    * You logged in `az login`
    * Youi saw your available accounts `az account list`
    * You selected an account `az account set --subscription <subscription-id>`
    * You verified the current account `az account show`

## Future / TODO
1. Linux VM drive storage should be private link only
1. Log Analytics should have private storage scope
1. Put Linux vm drive in storage resource groups
1. Script the download the VPN package from the p2s blade in the VNG
1. **Bug** The Azure CLI refuses to pars _subnet name_ `subnetAciName`. It is hard coded as a default value in the template until it is fixed


## Scripts
| Script                       | Required for Bastion | Required for P2S VPN | Purpose |
| ---------------------------- | -------------------- | -------------------- | ------- |
| 0-install-tools.sh           | yes | yes | install AWS CLI and jq |
| 1-login-az.sh                | yes | yes | renew azure cli credentials if expired |
| 2-create-resources.sh        | yes | yes | create a resource group if it does not exist |
| 3-create-vnet.sh             | yes | yes | Creates a vnet, subnets, DNS forwarder in a container. Adds DNS to VNET |
| 3b-create-keyvault.sh        | no  | no  | Creates a Key Vault and Private Link Endpoints | 
| 4-create-storage.sh          | no  | no  | Creates storage accounts, storage containers and Private Link Endpoints |
| 4b-create-cosmosdb.sh        | no  | no  | Create Cosmos DB instance and PLE connection.  No containers created |
| 5-create-monitor.sh          | no  | no  | Creates Log Analytics Workspace and Application Insights instance |
| 6-create-vm-linux.sh         | no  | No  | Create a simple virtual machine on the default subnet with no public IP with a log analytics workspace | 
| 7-create-bastion.sh          | yes | no  | Creates a bastion host |
| 8-create-vng-with-p2s.sh     | no  | yes | Creates a vng appliance with a P2S Address pool and self signed CA. Can VPN with the downloaded VPN Client config |
| 9-create-p2s.sh              | no  | yes | Creates and uploads the certificates using the Azure CLI. Can be used to add extra root certs |
| | | | | 
| 90-destroy-resource-group.sh           | n/a | n/a | Remove a resource group. May only works if public ips are disassociated or deleted |
| 91-purge-all-resource-groups.sh        | n/a | n/a | Remove everything in all resource groups leaving the resource groups |
| 92-purge-resource-groups-_resource_.sh | n/a | n/a | Remove everything in that Resource group |


The ARM templates are applied in `Incremental` mode so they can be used to update a configuration.
The purge scripts apply an ARM template in `Complete` mode.

The VNET gateway requires the resource groups and the vnet in order to be provisioned.

## Network IP Ranges
Pick network blocks that do not conflict with other networking. The network blocks below are non-routable (private) network blocks.
This project needs two private VNET ranges for the Azure components
1. Your VNET IP pool will be divided across seeral subnets
1. The Virtual Network Gateway address range managed by the network gateway

These network blocks are available for private VNETs. Typically we divide up the 10.x.x.x across multiple VNETS.
The each VNET divides its block among multiple subnets.

| block size | Full IP Range | Num IPs | Default mask | IP Bits | Network Bits | Network Class |
| ---------- | ------------- | ------- | ------------ | ------- | ------------ | ------------- |
| 24-bit     | 10.0.0.0 – 10.255.255.255   | 16777216 | 10.0.0.0/8 (255.0.0.0)       | 24  | 8   | single class A network |
| 20-bit     | 172.16.0.0 – 172.31.255.255 |  1048576 | 172.16.0.0/12 (255.240.0.0)  | 20  | 12  | 16 contiguous class B networks |
| 16-bit     | 192.168.0.0 – 192.168.255.255 |  65536 | 192.168.0.0/16 (255.255.0.0) | 16  | 16  |256 contiguous class C networks |


## VNET and Subnets
Internal subnets are on the 10.x.x.x network.  We use 10.0.0.0 - 10.0.2.255 for our internal subnets.


```mermaid
flowchart TD
    A[VNET<br/> VNet RG]
    A --> SubDef[default <br/>10.0.0.0/24 250]
    A --> SubData[data <br/>10.0.1.0/26 57]
    A --> SubCred[CredentialSecrets <br/>10.0.1.64/26 59]
    A --> SubBast[AzureBastionSubnet <br/>10.0.1.128/26 59]
    A --> SubAci[Azure Container Inst <br/>10.0.1.192/26 59]
    A --> SubVng[GatewaySubnet <br/>10.0.2.0/24  depends]

    SubDef --> SubDefRg[RG]
    SubDefRg --> NicVM[N.I.C.<br/>Linux]
    NicVM --> VM[Linux VM]

    SubCred --> SubCredRg[Secrets RG]
    SubCredRg --> NicKeyVault[N.I.C.<br/>Key Vault]
    NicKeyVault --> PleKV[Private Endpoint<br/>Key Vault]
    PleKV --> KeyVault[Key Vault]
    
    StorAct[Storage Account]
    StorFile[Storage Account<br/>File]
    StorBlob[Storage Account<br/>Blob] 

    CosmosDB[Cosmos DB]

    SubData --> SubPersistRg[Persist RG]
    
    SubPersistRg --> NicStorFile[N.I.C.<br/>File]
    NicStorFile --> PleFile[Private Endpoint<br/>Storage File]
    PleFile --> StorFile
    StorFile --> StorAct

    SubPersistRg --> NicStorBlob[N.I.C.<br/>Blob]
    NicStorBlob --> PleBlob[Private Endpoint<br/>Storage Blob]
    PleBlob --> StorBlob
    StorBlob --> StorAct

    SubPersistRg --> NicCosmos[N.I.C.<br/> Cosmos DB]
    NicCosmos --> PleCosmos[Private Endpoint<br/>Cosmos DB]
    PleCosmos --> CosmosDB

    SubBast --> SubBastRg[Bastion RG]
    SubBastRg --> Bastion[Bastion Host]
    Bastion --> PubaAst[Public IP<br>20.xx.xx.xx dynamic]

    SubAci --> SubVngRg[VNet RG]
    SubVngRg --> ACIDNS[DNS Forwarder<br/>Container]

    SubVng --> SubVngRg[VNet RG]
    SubVngRg --> VNG[Virtual Network Gateway]
    VNG --> PubVNG[Public IP<br>20.xx.xx.xx dynamic]
    VNG --> PoolVNG[Address Pool<br>172.16.0.0/26]
```
Diagrams created with https://mermaid-js.github.io/mermaid/#/

### DNS
The project's Azure resources often have both internal and public IP addresses under the same names.  
Those resources are blocked from public internet access by firewalls and are only reachable across the VPN tunnel.
This means that programs need the internal IP addresses that can be resolved via DNS inside Azure.
The VNET has an associated DNS forwarder that is implemented as an Azure Container Instance. The project deploys this awesome project  https://github.com/whiteducksoftware/az-dns-forwarder 
This provides Azure internal IP addresses for private link resourcesto clients of the VPN tunnel.
You can find the reason for the need for the DNS forwarder in a bunch of places. See references below.

## Resource Groups
This example isolates related components components into their own Resource groups, Networking, Data Stores, etc.
Resource Group partitioning makes it easier to cleanly build and tear down ephemeral components while leaving core and persistence services running

| Resource Group | Description | Purge Script |
| - | - | - |
| Example-VNET-RG     | VNet and Subnets and VNG| 92-purge-resource-group-vnet.sh |
| Example-persist-RG  | Storage accounts, Cosmos and private link endpoints | 92-purge-resource-group-persist.sh |
| Example-bastion-RG  | Bastion host | 92-purge-resource-group-bastion.sh |
| Esample-secrets-RG  | Key Vaults | 92-purge-resource-group-keyvault.sh |
| Example-RG          | default resource group - compute, App Insights | 92-purge-resource-group-ephememeral |

A Virtual Network Gateway must be in the same Resource Group as the VNET itself.

## Accessing Storage Containers via Portal
The portal will **forbid you from browsing your Storage Containers** unless you add your home machine IP to the firewall approve list
1. Drill into your _storage account_ inthe portal
1. Click on `Networking`
1. Look at `Firewalls and virtual networks`
1. Click the checkbox next to _Add your client IP address_
1. Click on `Save`
1. Verify your ip is in the address range list

## Point to Site VPN
Most of the resources in this project are blocked from internet access.
We can access those resources using a Point-to-Site (P2s) VPN tunnel.

```mermaid
flowchart LR
    LM[Local Machine] -- Internet --- VNG[VNG with P2S] -- VNET/Subnet --- AR[Azure Resources]
```

### Demonstrating just Point To Site VPN
The Point to Site only requires the resource groups, the vnet and the VNG.  
This means only need to run those three scripts to, 2,3,8, to get a working VPN connection.
The scripts will automatically create the certificates and upload them to Azure.
VPN configuration files are available for Windows and other platforms via the Gateway P2S blade.

### Windows VPN
1. Download the VPN configuration files from the portal.
1. Double click the generated `pfx` file in the _certs_ folder to load that certificate into your windows certificate store.

### Troubleshooting VPN DNS 
Internal IP address resolution for privatelink and other resources should be avaialble as soon as you connect via VPN.

Run an nslookup against your PLE endpoints. If they return external IPs then you are not using the VNET DNS server that we deployed as a container.
In that case it could be that your VPN tunnel (PPP) is a lower priority than your network connection.
In my case my ethernet connection was of a equivalent Metric which meant either public or private DNS could be used.

#### Problem
Resolves to external IPs when ethernet is connected because Ethernet Metric is same as VPN tunnel with lower index.
```
PS C:\Users\joe> netsh interface ipv4 show interfaces

Idx     Met         MTU          State                Name
---  ----------  ----------  ------------  ---------------------------
 60          25        1400  connected     FsiExample-VNET
  1          75  4294967295  connected     Loopback Pseudo-Interface 1
 23          70        1500  disconnected  Wi-Fi
  4          25        1500  connected     Ethernet
  5          25        1500  disconnected  Local Area Connection* 1
 12          65        1500  disconnected  Bluetooth Network Connection
 25          25        1500  disconnected  Local Area Connection* 2
 24          15        1500  connected     vEthernet (Default Switch)
 11          35        1500  connected     VMware Network Adapter VMnet1
 20          35        1500  connected     VMware Network Adapter VMnet8
 19          35        1500  connected     Azure Sphere
 56          15        1500  connected     vEthernet (WSL)

PS C:\Users\joe> nslookup   fsiexample0storage.blob.core.windows.net
Server:  Fios_Quantum_Gateway.fios-router.home
Address:  192.168.1.1

Non-authoritative answer:
Name:    blob.bn9prdstr05a.store.core.windows.net
Address:  52.239.174.132
Aliases:  fsiexample0storage.blob.core.windows.net
          fsiexample0storage.privatelink.blob.core.windows.net
```

#### Correct
Resolves to internal Azure IPs when ethernet disconnected because Wi-Fi is lower priority metric than the VPN tunnel.
```
PS C:\Users\joe> netsh interface ipv4 show interfaces

Idx     Met         MTU          State                Name
---  ----------  ----------  ------------  ---------------------------
 60          35        1400  connected     FsiExample-VNET
  1          75  4294967295  connected     Loopback Pseudo-Interface 1
 23          45        1500  connected     Wi-Fi
  4           5        1500  disconnected  Ethernet
  5          25        1500  disconnected  Local Area Connection* 1
 12          65        1500  disconnected  Bluetooth Network Connection
 25          25        1500  disconnected  Local Area Connection* 2
 24          15        1500  connected     vEthernet (Default Switch)
 11          35        1500  connected     VMware Network Adapter VMnet1
 20          35        1500  connected     VMware Network Adapter VMnet8
 19          35        1500  connected     Azure Sphere
 56          15        1500  connected     vEthernet (WSL)

PS C:\Users\joe> nslookup   fsiexample0storage.blob.core.windows.net
Server:  UnKnown
Address:  10.0.1.196

Non-authoritative answer:
Name:    fsiexample0storage.privatelink.blob.core.windows.net
Address:  10.0.1.4
Aliases:  fsiexample0storage.blob.core.windows.net
```


## References
Incomplete list of resources used in creating this project.

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

Azure Private Link and DNS
* https://docs.microsoft.com/en-us/azure/private-link/private-endpoint-dns

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

Azure DNS over VPN Tunnels
* https://github.com/dmauser/PrivateLink/tree/master/DNS-Integration-P2S
* https://docs.microsoft.com/en-us/answers/questions/64223/issue-with-resolving-hostnames-while-connected-to.html

VM Agents
* https://github.com/MicrosoftDocs/azure-docs/blob/master/articles/virtual-machines/extensions/oms-linux.md
* https://docs.microsoft.com/en-us/azure/virtual-machines/extensions/agent-dependency-linux
