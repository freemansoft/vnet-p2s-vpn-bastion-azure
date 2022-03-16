#!/bin/bash
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
root_name="FsiExample"

# decided to not prefix the resource names with the resource type rg, ia, cl...
AZURE_RESOURCE_GROUP="$root_name-RG"

NOW_PUBLISHED_AT="$(date +%F-%T)"

# pick unused address range
AZURE_VNET_NAME="$root_name-VNET"
# 10.0.0.0 - 10.0.255.255
AZURE_VNET_NETWORK="10.0.0.0/16"

# 10.0.0.0 - 10.0.0.255
VNET_SUBNET_DEFAULT_NETWORK="10.0.0.0/24"
VNET_SUBNET_DEFAULT_NAME="default"
# 10.0.1.0 - 10.0.1.63
VNET_SUBNET_DATA_NETWORK="10.0.1.0/26"
VNET_SUBNET_DATA_NAME="data"
# 10.0.1.64 - 10.0.1.127
VNET_SUBNET_CREDENTIALS_NETWORK="10.0.1.64/26"
VNET_SUBNET_CREDENTIALS_NAME="CredentialsSecrets"
# 10.0.1.128 - 10.0.1.191
VNET_SUBNET_BASTION_NETWORK="10.0.1.128/26"
VNET_SUBNET_BASTION_NAME="AzureBastionSubnet"
# 10.0.1.192 - 10.0.1.255
#VNET_SUBNET_OTHER_NETWORK="10.0.1.192/26"
#VNET_SUBNET_OTHER_NAME="AnotherSubnet"
# 10.0.2.0 - 10.0.2.255
VNET_SUBNET_VNG_NETWORK="10.0.2.0/24"
VNET_SUBNET_VNG_NAME="GatewaySubnet"

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

STORAGE_ACCOUNT_NAME="fsiexample0storage"
# storage accounts need to be in lower case
STORAGE_ACCOUNT_NAME="${root_name,,}0storage"
STORAGE_CONTAINER_BLOB_1_NAME="container-1"
STORAGE_CONTAINER_BLOB_2_Name="container-2"

PE_STORAGE_ACCOUNT_BLOB_NAME="$root_name-PeStorageBlob"
PE_STORAGE_ACCOUNT_FILE_NAME="$root_name-PeStorageFile"

VM_UBUNTU_NAME="$root_name-VmLinux"
VM_UBUNTU_USERNAME="azureuser"
VM_UBUNTU_PASSWORD="1WeakPassword"
VM_UBUNTU_OS_VERSION="18.04-LTS"
VM_SIZE="Standard_B2s"

LOG_ANALYTICS_WORKSPACE_NAME="$root_name-LAW"
APP_INSIGHTS_NAME="$root_name-AI"

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