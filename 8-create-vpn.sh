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

echo "-------------Gateway and Public IP--------"
az deployment group create --resource-group "$AZURE_RESOURCE_GROUP" \
     --template-file templates/template-vpn.json \
     --parameters \
     azureRegionPrimary=$AZURE_REGION \
     vnetNetworkName=$AZURE_VNET_NAME \
     subnetVngName=$VNET_SUBNET_VNG_NAME \
     virtualNetworkGatewaysVngName=$VNGS_VNG_NAME \
     publicIPAddressesVngName=$PUBLIC_IP_VNG_NAME \
     addressGatewayPeering=$VNG_ADDRESS_PEERING
