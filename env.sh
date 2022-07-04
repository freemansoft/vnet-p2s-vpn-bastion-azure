#!/usr/bin/env bash
#
# These addresses should be sync'd with the templates

RED='\e[1;31m'
GREEN='\e[1;32m'
PURPLE='\e[1;35m'
WHITE='\e[1;37m'
NC='\e[1;0m'

# should set the subscription
AZURE_REGION="eastus2"
# will use your login's default
#AZURE_SUBSCRIPTION=[to be filled]


# Could add version # to name  to avoid complications with soft-deleted keyvaults while testing
# keyvault deletes are soft deletes with a purgable recovery == 90 days 2021/07
# root_name should not have dashes in it.  Not all names can accept dashes
root_name="FsiExample"

# Suffix resource groups with "-RG"
# GLOBAL RGs
AZURE_RESOURCE_GROUP_VNET="$root_name-vnet-RG"

# HUB RGs
# Virtnal Network Gateway (VNG) must be in the same resource group as the VNET that it is the gateway for
AZURE_RESOURCE_GROUP_BASTION="$root_name-bastion-RG"
AZURE_RESOURCE_GROUP_VNG="$AZURE_RESOURCE_GROUP_VNET"

# Spoke RGs
AZURE_RESOURCE_GROUP_APP="$root_name-app-RG"
AZURE_RESOURCE_GROUP_PERSIST="$root_name-persist-RG"
AZURE_RESOURCE_GROUP_SECRETS="$root_name-secret-RG"

NOW_PUBLISHED_AT="$(date +%F-%T)"

# Addresses calculated with https://www.calculator.net/ip-subnet-calculator.htm
######### ######### ######### #########  
# Spoke / Control VNET
# pick unused address range
AZURE_VNET_HUB_NAME="$root_name-hub-VNET"
# 10.0.0.1 - 10.0.63.254 4096 IPs
AZURE_VNET_HUB_NETWORK="10.0.0.0/20"

# MS Azure Minimum Size
# 10.0.0.0 - 10.0.0.255
VNET_HUB_SUBNET_VNG_NETWORK="10.0.0.0/24"
VNET_HUB_SUBNET_VNG_NAME="Gateway"
# 10.0.1.0 - 10.0.1.63
VNET_HUB_SUBNET_DNS_ACI_NETWORK="10.0.1.0/26"
VNET_HUB_SUBNET_DNS_ACI_NAME="DnsAci"
# 10.0.1.64 - 10.0.1.127
VNET_HUB_SUBNET_SHELL_ACI_NETWORK="10.0.1.64/26"
VNET_HUB_SUBNET_SHELL_ACI_NAME="CloudShellAci"
# MS Azure minimum size
# 10.0.1.128 - 10.0.1.191
VNET_HUB_SUBNET_BASTION_NETWORK="10.0.1.128/26"
VNET_HUB_SUBNET_BASTION_NAME="AzureBastion"
# primarily cloudshell storage
# 10.0.1.192 - 1.0.1.254
VNET_HUB_SUBNET_DATA_NETWORK="10.0.1.192/26"
VNET_HUB_SUBNET_DATA_NAME="Storage"


######### ######### ######### ######### 
# Landing Zone / application VNET
# pick unused address range
AZURE_VNET_SPOKE_NAME="$root_name-spoke-VNET"
# 10.0.16.1 - 10.0.31.255 4096 IPs
AZURE_VNET_SPOKE_NETWORK="10.0.16.0/20"

# 10.0.16.0 - 10.0.16.255
VNET_SPOKE_SUBNET_DEFAULT_NETWORK="10.0.16.0/24"
VNET_SPOKE_SUBNET_DEFAULT_NAME="default"

# 10.0.17.0 - 10.0.17.63
VNET_SPOKE_SUBNET_DATA_NETWORK="10.0.17.0/26"
VNET_SPOKE_SUBNET_DATA_NAME="Storage"
# 10.0.17.64 - 10.0.17.127
VNET_SPOKE_SUBNET_SECRETS_NETWORK="10.0.17.64/26"
VNET_SPOKE_SUBNET_SECRETS_NAME="CredentialsSecrets"



VNGS_VNG_NAME="$root_name-VNG"
PUBLIC_IP_VNG_NAME="$root_name-VNG-IP"

P2S_PUBLIC_CERT_NAME="AzureVPN"
P2S_CLIENT_CERT_NAME="AzureClientVPN"
P2S_CERT_PASSWORD="1234"
# pick unused address range
# 172.31.2.0 - 172.31.2.255
#P2S_ADDRESS_POOL="172.31.2.0/24"
# pick unused address range
# 172.16.0.0 - 172.16.0.??
P2S_ADDRESS_POOL="172.16.0.0/26"

BASTION_HOST_NAME="$root_name-Bastion"
PUBLIC_IP_BASTION_NAME="$root_name-Bastion-IP"

# cosmos db must be lower case
SPOKE_COSMOS_DB_INSTANCE_NAME="${root_name,,}-cosmos"
SPOKE_COSMOS_DB_PE_NAME="$root_name-PeCosmos"

# must be lower case with no dashes
SPOKE_STORAGE_ACCOUNT_NAME="${root_name,,}0storage"
SPOKE_STORAGE_CONTAINER_BLOB_1_NAME="container-1"
SPOKE_STORAGE_CONTAINER_BLOB_2_Name="container-2"

SPOKE_STORAGE_ACCT_PE_BLOB_NAME="$root_name-PeStorageBlob"
SPOKE_STORAGE_ACCT_PE_FILE_NAME="$root_name-PeStorageFile"

# sometimes add number to the keyvault name because of soft delete pain - being lazy
SPOKE_KEY_VAULT_NAME="$root_name-kv-4"
# PE -> Private Link Endpoint
SPOKE_KEY_VAULT_PE_NAME="$root_name-PeKeyVault"

VM_UBUNTU_NAME="$root_name-VmLinux"
VM_UBUNTU_USERNAME="azureuser"
VM_UBUNTU_PASSWORD="1WeakPassword"
VM_UBUNTU_OS_VERSION="18.04-LTS"
VM_SIZE="Standard_B2s"

SPOKE_LOG_ANALYTICS_WS_NAME="$root_name-LAW"
SPOKE_APP_INSIGHTS_NAME="$root_name-AI"

# Use git commands.  We know this is a git repo and that you had to use git to get it
# This should reall be the git tag but I don't tag in my demo repos
# long commit hash
COMMIT_HASH="$(git log -1 --format='%H')"
# short commit hash
COMMIT_HASH="$(git log --pretty=format:'%h' -n 1)"
CURRENT_BRANCH="$(git branch --show-current)"
CURRENT_REPO="$(basename $(git remote get-url origin) .git)"
VERSION=$CURRENT_REPO:$CURRENT_BRANCH:$COMMIT_HASH
# echo $VERSION
PROJECT="VNet IaC Example"