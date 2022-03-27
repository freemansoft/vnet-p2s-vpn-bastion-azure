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

echo -e "${PURPLE}--------------Cosmos DB-------------${NC}"
az deployment group create --resource-group "$AZURE_RESOURCE_GROUP_PERSIST" \
    --template-file templates/template-cosmos.json \
    --parameters \
    azureRegionPrimary=$AZURE_REGION \
    cosmosInstanceName=$COSMOS_DB_INSTANCE_NAME \
    lastPublishedAt="$NOW_PUBLISHED_AT" \
    version="$VERSION" \
    project="$PROJECT" \


# echo -e "${PURPLE}--------------Cosmos DB Private Endpoints-------------${NC}"
az deployment group create --resource-group "$AZURE_RESOURCE_GROUP_PERSIST" \
    --template-file templates/template-cosmos-endpoints.json \
    --parameters \
    azureRegionPrimary=$AZURE_REGION \
    vnetResourceGroup=$AZURE_RESOURCE_GROUP_VNET \
    vnetNetworkName=$AZURE_VNET_NAME \
    subnetDataName="$VNET_SUBNET_DATA_NAME" \
    cosmosInstanceName=$COSMOS_DB_INSTANCE_NAME \
    privateEndpoints_cosmos=$COSMOS_DB_PE_NAME \
    lastPublishedAt="$NOW_PUBLISHED_AT" \
    version="$VERSION" \
    project="$PROJECT" \
