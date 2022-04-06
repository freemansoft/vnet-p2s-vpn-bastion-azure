#!/usr/bin/env bash
#
# Assumes 
#   azure cli is installed
#   jq is installed
#   default subscription
# Deprovisions
#   Everything in the resource group
set -e

# Edit env.sh to your preferences
DIR="$(cd "$(dirname "$0")" && pwd)"
source $DIR/env.sh


# echo "removing everything in $AZURE_RESOURCE_GROUP_VNET via empty template"
# # Rely on the "complete" mode with an empty template.  It should remove all resources
# az deployment group create -g $AZURE_RESOURCE_GROUP_VNET --template-file templates/template-empty.json --mode Complete

echo "removing everything in $AZURE_RESOURCE_GROUP_VNET other than the vnet itself"
# Rely on the "complete" task with just the vnet template to clear everything other than the vnet
az deployment group create \
    --mode complete \
    --resource-group "$AZURE_RESOURCE_GROUP_VNET" \
    --template-file templates/template-vnet.json \
    --parameters \
    azureRegionPrimary=$AZURE_REGION \
    vnetNetworkHub=$AZURE_VNET_HUB_NETWORK \
    vnetNetworkHubName=$AZURE_VNET_HUB_NAME \
    vnetNetworkSpoke=$AZURE_VNET_SPOKE_NETWORK \
    vnetNetworkSpokeName=$AZURE_VNET_SPOKE_NAME \
    subnetDefaultNetwork=$VNET_SUBNET_DEFAULT_NETWORK \
    subnetDefaultName=$VNET_SUBNET_DEFAULT_NAME \
    subnetDataNetwork=$VNET_SUBNET_DATA_NETWORK \
    subnetDataName=$VNET_SUBNET_DATA_NAME \
    subnetCredentialsNetwork=$VNET_SUBNET_SECRETS_NETWORK \
    subnetCredentialsName=$VNET_SUBNET_SECRETS_NAME \
    subnetBastionNetwork=$VNET_SUBNET_BASTION_NETWORK \
    subnetBastionName=$VNET_SUBNET_BASTION_NAME \
    subnetVngNetwork=$VNET_SUBNET_VNG_NETWORK \
    subnetVngName=$VNET_SUBNET_VNG_NAME \
    lastPublishedAt="$NOW_PUBLISHED_AT" \
    version="$VERSION" \
    project="$PROJECT" \
    subnetDnsAciNetwork=$VNET_SUBNET_DNS_ACI_NETWORK \
#   this won't parse :-(
#    subnetDnsAciName=$VNET_SUBNET_DNS_ACI_NAME \ 


