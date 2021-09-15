#!/bin/bash
#
# These addresses should be sync'd with the templates

# should set the subscription
AZURE_REGION="eastus2"
#AZURE_SUBSCRIPTION=[to be filled]


# add version # to name  to avoid complications with soft-deleted keyvaults while testing
# keyvault deletes are soft deletes witha purgable recovery == 90 days 2021/07
root_name="VNET-Example"

# decided to not prefix the resource names with the resource type rg, ia, cl...
AZURE_RESOURCE_GROUP="RG-$root_name"


# pick unused address range
AZURE_VNET_NAME="$root_name"
# 10.0.0.0 - 10.0.255.255
AZURE_VNET_NETWORK="10.0.0.0/16"

# 10.0.0.0 - 10.0.0.255
VNET_SUBNET_DEFAULT_NETWORDK="10.0.0.0/24"
VNET_SUBNET_DEFAULT_NAME="default"
# 10.0.1.0 - 10.0.1.63
VNET_SUBNET_DATA_NETWORK="10.0.1.0/26"
VNET_SUBNET_DATA_NAME="data"
# 10.0.1.64 - 10.0.1.127
VNET_SUBNET_CREDENTIALS_NETWORK="10.0.1.64/26"
VNET_SUBNET_CREDENTIALS_NAME="credentials-secrets"
# 10.0.1.128 - 10.0.1.191
VNET_SUBNET_BASTION_NETWORK="10.0.1.128/26"
VNET_SUBNET_BASTION_NAME="AzureBastionSubnet"
# 10.0.1.192 - 10.0.1.255
#VNET_SUBNET_OTHER_NETWORK="10.0.1.192/26"
#VNET_SUBNET_OTHER_NAME="AnotherSubnet"
# 10.0.2.0 - 10.0.2.255
VNET_SUBNET_VNG_NETWORK="10.0.2.0/24"
VNET_SUBNET_VNG_NAME="GatewaySubnet"
VNG_ADDRESS_PEERING="10.0.2.254"

VNGS_VNG_NAME="VNG--$root_name"
BASTION_HOST_NAME="Bastion-$root_name"
PUBLIC_IP_VNG_NAME="VNG-IP-$root_name"
PUBLIC_IP_BASTION_NAME="Bastion-IP-$root_name"

# pick unused address range
# 172.31.2.0 - 172.31.2.255
P2S_ADDRESS_POOL="172.31.2.0/24"

STORAGE_ACCOUNT_NAME="storage0vnet0example"
STORAGE_CONTAINER_BLOB_1_NAME="container-1"
STORAGE_CONTAINER_BLOB_2_Name="container-2"

PE_STORAGE_ACCOUNT_BLOB_NAME="pe-$STORAGE_ACCOUNT_NAME-blob"
PE_STORAGE_ACCOUNT_FILE_NAME="pe-$STORAGE_ACCOUNT_NAME-file"

VM_NAME="vm-$root_name"
VM_ADMIN_USERNAME="azureuser"
VM_ADMIN_PASSWORD="1WeakPassword"
VM_UBUNTU_OS_VERSION="18.04-LTS"
VM_SIZE="Standard_B2s"

LOG_ANALYTICS_WORKSPACE_NAME="LAW-$root_name"
APP_INSIGHTS_NAME="AI-$root_name"