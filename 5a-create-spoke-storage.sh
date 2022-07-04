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
az deployment group create --resource-group "$AZURE_RESOURCE_GROUP_PERSIST" \
    --template-file templates/template-spoke-storage.json \
    --parameters \
    azureRegionPrimary=$AZURE_REGION \
    storageAccountName=$SPOKE_STORAGE_ACCOUNT_NAME \
    storageContainerBlob1Name=$SPOKE_STORAGE_CONTAINER_BLOB_1_NAME \
    storageContainerBlob2Name=$SPOKE_STORAGE_CONTAINER_BLOB_2_Name \
    lastPublishedAt="$NOW_PUBLISHED_AT" \
    version="$VERSION" \
    project="$PROJECT" \

# Private Link Endpoints inside the VNET
echo -e "${PURPLE}--------------Storage Account Private Endpoints-------------${NC}"
az deployment group create --resource-group "$AZURE_RESOURCE_GROUP_PERSIST" \
    --template-file templates/template-spoke-storage-endpoints.json \
    --parameters \
    azureRegionPrimary=$AZURE_REGION \
    vnetResourceGroup="$AZURE_RESOURCE_GROUP_VNET" \
    vnetNetworkName="$AZURE_VNET_SPOKE_NAME" \
    subnetSpokeDataName="$VNET_SPOKE_SUBNET_DATA_NAME" \
    storageAccountName=$SPOKE_STORAGE_ACCOUNT_NAME \
    privateEndpoints_storageAccount_blobName=$SPOKE_STORAGE_ACCT_PE_BLOB_NAME \
    privateEndpoints_storageAccount_fileName=$SPOKE_STORAGE_ACCT_PE_FILE_NAME \
    lastPublishedAt="$NOW_PUBLISHED_AT" \
    version="$VERSION" \
    project="$PROJECT" \
