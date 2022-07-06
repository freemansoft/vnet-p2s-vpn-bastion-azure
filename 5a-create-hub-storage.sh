#!/usr/bin/env bash
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

# storage is a global service so there is no subnet
echo -e "${PURPLE}--------------Storage Account-------------${NC}"
az deployment group create --resource-group "$AZURE_RESOURCE_GROUP_HUB_PERSIST" \
    --template-file templates/template-storage.json \
    --parameters \
    azureRegionPrimary=$AZURE_REGION \
    storageAccountName=$HUB_STORAGE_ACCOUNT_NAME \
    storageContainerBlob1Name=$HUB_STORAGE_CONTAINER_BLOB_1_NAME \
    storageContainerBlob2Name=$HUB_STORAGE_CONTAINER_BLOB_2_Name \
    lastPublishedAt="$NOW_PUBLISHED_AT" \
    version="$VERSION" \
    project="$PROJECT" \

# Private Link Endpoints inside the VNET
echo -e "${PURPLE}--------------Storage Account Private Endpoints-------------${NC}"
az deployment group create --resource-group "$AZURE_RESOURCE_GROUP_HUB_PERSIST" \
    --template-file templates/template-storage-endpoints.json \
    --parameters \
    azureRegionPrimary=$AZURE_REGION \
    vnetResourceGroup="$AZURE_RESOURCE_GROUP_VNET" \
    vnetNetworkName="$AZURE_VNET_HUB_NAME" \
    storageSubnetName="$VNET_HUB_SUBNET_STORAGE_NAME" \
    storageAccountName=$HUB_STORAGE_ACCOUNT_NAME \
    privateEndpoints_storageAccount_blobName=$HUB_STORAGE_ACCT_PE_BLOB_NAME \
    privateEndpoints_storageAccount_fileName=$HUB_STORAGE_ACCT_PE_FILE_NAME \
    lastPublishedAt="$NOW_PUBLISHED_AT" \
    version="$VERSION" \
    project="$PROJECT" \
