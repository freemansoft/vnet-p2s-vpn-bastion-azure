#!/bin/bash
#
# Assumes 
#   azure cli is installed
#   jq is installed
#   default subscription
# Deprovisions
#   Everything in the vnet but leaves the vnet
set -e

# Edit env.sh to your preferences
DIR="$(cd "$(dirname "$0")" && pwd)"
source $DIR/env.sh

echo "removing everything in $AZURE_VNET_NAME via vnet template"
# rely on the "Complete" mode with just the vnet/subnets. That should remove everything else
az deployment group create --resource-group "$AZURE_RESOURCE_GROUP" \
     --template-file templates/template-vnet.json \
     --parameters \
     azureRegionPrimary=$AZURE_REGION \
     vnetNetwork=$AZURE_VNET_NETWORK \
     vnetNetworkName=$AZURE_VNET_NAME \
     subnetDefaultNetwork=$VNET_SUBNET_DEFAULT_NETWORK \
     subnetDefaultName=$VNET_SUBNET_DEFAULT_NAME \
     subnetDataNetwork=$VNET_SUBNET_DATA_NETWORK \
     subnetDataName=$VNET_SUBNET_DATA_NAME \
     subnetCredentialsNetwork=$VNET_SUBNET_CREDENTIALS_NETWORK \
     subnetCredentialsName=$VNET_SUBNET_CREDENTIALS_NAME \
     subnetBastionNetwork=$VNET_SUBNET_BASTION_NETWORK \
     subnetBastionName=$VNET_SUBNET_BASTION_NAME \
     subnetVngNetwork=$VNET_SUBNET_VNG_NETWORK \
     subnetVngName=$VNET_SUBNET_VNG_NAME \
     lastPublishedAt="$NOW_PUBLISHED_AT" \
     version="$VERSION" \
     project="$PROJECT" \
     --mode Complete
