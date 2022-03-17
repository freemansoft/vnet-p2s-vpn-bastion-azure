#!/bin/bash
#
# Assumes 
#   azure cli is installed
#   jq is installed
#   default subscription
# Provisions
#   VNET via ARM template

set -e

# Edit env.sh to your preferences
DIR="$(cd "$(dirname "$0")" && pwd)"
source $DIR/env.sh

echo "This will take several minutes "

echo -e "${PURPLE}-------------Bastion and Public IP--------${NC}"
az deployment group create --resource-group "$AZURE_RESOURCE_GROUP_BASTION" \
     --template-file templates/template-bastion.json \
     --parameters \
     azureRegionPrimary=$AZURE_REGION \
     vnetResourceGroup=$AZURE_RESOURCE_GROUP_VNET \
     vnetNetworkName=$AZURE_VNET_NAME \
     subnetBastionName=$VNET_SUBNET_BASTION_NAME \
     bastionHostName=$BASTION_HOST_NAME \
     publicIPAddressesBastionName=$PUBLIC_IP_BASTION_NAME \
     lastPublishedAt="$NOW_PUBLISHED_AT" \
     version="$VERSION" \
     project="$PROJECT" \
