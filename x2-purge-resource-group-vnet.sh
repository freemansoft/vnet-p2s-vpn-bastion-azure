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


# echo "removing everything in $AZURE_RESOURCE_GROUP_HUB_VNET via empty template"
# # Rely on the "complete" mode with an empty template.  It should remove all resources
# az deployment group create -g $AZURE_RESOURCE_GROUP_HUB_VNET --template-file templates/template-empty.json --mode Complete

echo "removing everything in $AZURE_RESOURCE_GROUP_HUB_VNET other than the vnet and subnets"
# Rely on the "complete" task with just the vnet template to clear everything other than the vnet

echo -e "${PURPLE}-------------------Clearing Spoke VNET / subnets ----------------${NC}"
az deployment group create \
    --complete
    --resource-group "$AZURE_RESOURCE_GROUP_SPOKE_VNET" \
    --template-file templates/template-vnet-spoke-peer.json \
    --parameters \
        azureRegionPrimary=$AZURE_REGION \
        vnetNetworkHub="$AZURE_VNET_HUB_NETWORK" \
        vnetNetworkHubName="$AZURE_VNET_HUB_NAME" \
        vnetNetworkSpoke="$AZURE_VNET_SPOKE_NETWORK" \
        vnetNetworkSpokeName="$AZURE_VNET_SPOKE_NAME" \
        subnetSpokeDefaultNetwork="$VNET_SPOKE_SUBNET_DEFAULT_NETWORK" \
        subnetSpokeDefaultName="$VNET_SPOKE_SUBNET_DEFAULT_NAME" \
        subnetSpokeDataNetwork="$VNET_SPOKE_SUBNET_STORAGE_NETWORK" \
        subnetStorageName="$VNET_SPOKE_SUBNET_STORAGE_NAME" \
        subnetSpokeCredentialsNetwork="$VNET_SPOKE_SUBNET_SECRETS_NETWORK" \
        subnetSpokeCredentialsName="$VNET_SPOKE_SUBNET_SECRETS_NAME" \
        lastPublishedAt="$NOW_PUBLISHED_AT" \
        version="$VERSION" \
        project="$PROJECT" 

echo -e "${PURPLE}----------------Clearing Hub VNET / Subnets----------${NC}"
az deployment group create 
    --resource-group "$AZURE_RESOURCE_GROUP_HUB_VNET" \
    --template-file templates/template-vnet-hub.json \
    --parameters \
        azureRegionPrimary=$AZURE_REGION \
        vnetNetworkHub="$AZURE_VNET_HUB_NETWORK" \
        vnetNetworkHubName="$AZURE_VNET_HUB_NAME" \
        subnetHubBastionNetwork="$VNET_HUB_SUBNET_BASTION_NETWORK" \
        subnetHubBastionName="$VNET_HUB_SUBNET_BASTION_NAME" \
        subnetHubVngNetwork="$VNET_HUB_SUBNET_VNG_NETWORK" \
        subnetHubVngName="$VNET_HUB_SUBNET_VNG_NAME" \
        subnetHubShellAciName="$VNET_HUB_SUBNET_SHELL_ACI_NAME" \
        subnetHubShellAciNetwork="$VNET_HUB_SUBNET_SHELL_ACI_NETWORK" \
        subnetHubStorageName="$VNET_HUB_SUBNET_STORAGE_NAME" \
        subnetHubStorageNetwork="$VNET_HUB_SUBNET_STORAGE_NETWORK" \
        lastPublishedAt="$NOW_PUBLISHED_AT" \
        version="$VERSION" \
        project="$PROJECT" \
        subnetHubDnsAciNetwork="$VNET_HUB_SUBNET_DNS_ACI_NETWORK" \
        subnetHubDnsAciName="$VNET_HUB_SUBNET_DNS_ACI_NAME" 


