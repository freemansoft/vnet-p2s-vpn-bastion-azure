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
echo -e "${PURPLE}--------------Storage Account Spoke-------------${NC}"
az deployment group create --resource-group "$AZURE_RESOURCE_GROUP_SPOKE_PERSIST" \
    --template-file templates/template-storage.json \
    --parameters \
    azureRegionPrimary=$AZURE_REGION \
    storageAccountName=$SPOKE_STORAGE_ACCOUNT_NAME \
    storageContainerBlob1Name=$SPOKE_STORAGE_CONTAINER_BLOB_1_NAME \
    storageContainerBlob2Name=$SPOKE_STORAGE_CONTAINER_BLOB_2_Name \
    lastPublishedAt="$NOW_PUBLISHED_AT" \
    version="$VERSION" \
    project="$PROJECT" \

# Private Link Endpoints inside the VNET
echo -e "${PURPLE}--------------Storage Account Private Endpoints Spoke-------------${NC}"
az deployment group create --resource-group "$AZURE_RESOURCE_GROUP_SPOKE_PERSIST" \
    --template-file templates/template-storage-endpoints.json \
    --parameters \
    azureRegionPrimary=$AZURE_REGION \
    vnetResourceGroup="$AZURE_RESOURCE_GROUP_SPOKE_VNET" \
    vnetNetworkName="$AZURE_VNET_SPOKE_NAME" \
    subnetStorageName="$VNET_SPOKE_SUBNET_STORAGE_NAME" \
    storageAccountName=$SPOKE_STORAGE_ACCOUNT_NAME \
    privateEndpoints_storageAccount_blobName=$SPOKE_STORAGE_ACCT_PE_BLOB_NAME \
    privateEndpoints_storageAccount_fileName=$SPOKE_STORAGE_ACCT_PE_FILE_NAME \
    lastPublishedAt="$NOW_PUBLISHED_AT" \
    version="$VERSION" \
    project="$PROJECT" \
