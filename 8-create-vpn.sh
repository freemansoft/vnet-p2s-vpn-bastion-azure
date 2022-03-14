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

# created here because we probably can create p2s config all in one template in teh future
# only creates if missing
source ./create-certificates.sh

# Occasionally seen this run a long time > 10 min
echo -e "${PURPLE}-------------Gateway and Public IP--------${NC}"
echo -e "${PURPLE}---This will take several minutes---${NC}"
az deployment group create --resource-group "$AZURE_RESOURCE_GROUP" \
     --template-file templates/template-vpn.json \
     --parameters \
     azureRegionPrimary=$AZURE_REGION \
     vnetNetworkName=$AZURE_VNET_NAME \
     subnetVngName=$VNET_SUBNET_VNG_NAME \
     virtualNetworkGatewaysVngName=$VNGS_VNG_NAME \
     publicIPAddressesVngName=$PUBLIC_IP_VNG_NAME \
     addressGatewayPeering=$VNG_ADDRESS_PEERING \
     lastPublishedAt="$NOW_PUBLISHED_AT" \
     version="$VERSION" \
     project="$PROJECT" \
