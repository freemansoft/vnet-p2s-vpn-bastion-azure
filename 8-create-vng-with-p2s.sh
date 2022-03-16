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

# Occasionally seen this run a long time > 10 min
echo -e "${PURPLE}-------------Gateway and Public IP--------${NC}"
echo -e "This will take probably 20 minutes"
az deployment group create --resource-group "$AZURE_RESOURCE_GROUP" \
     --template-file templates/template-vng-vpn.json \
     --parameters \
     azureRegionPrimary=$AZURE_REGION \
     vnetNetworkName=$AZURE_VNET_NAME \
     subnetVngName=$VNET_SUBNET_VNG_NAME \
     virtualNetworkGatewaysVngName=$VNGS_VNG_NAME \
     publicIPAddressesVngName=$PUBLIC_IP_VNG_NAME \
     p2sClientAddressPool="$P2S_ADDRESS_POOL" \
     lastPublishedAt="$NOW_PUBLISHED_AT" \
     version="$VERSION" \
     project="$PROJECT" \

# invoke the script that creates certs and uploads them
bash $DIR/9-create-p2s.sh
