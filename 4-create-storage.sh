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

echo "--------------Storage Account-------------"
az deployment group create --resource-group "$AZURE_RESOURCE_GROUP" \
    --template-file templates/template-storage.json \
    --parameters \
     azureRegionPrimary=$AZURE_REGION \
     storageAccountName=$STORAGE_ACCOUNT_NAME \
     storageContainerBlob1Name=$STORAGE_CONTAINER_BLOB_1_NAME \
     storageContainerBlob2Name=$STORAGE_CONTAINER_BLOB_2_Name

echo "--------------Storage Account Private Endpoints-------------"
az deployment group create --resource-group "$AZURE_RESOURCE_GROUP" \
    --template-file templates/template-storage-endpoints.json \
    --parameters \
     azureRegionPrimary=$AZURE_REGION \
     vnetNetworkName=$AZURE_VNET_NAME \
     storageAccountName=$STORAGE_ACCOUNT_NAME \
     privateEndpoints_storageAccount_blobName=$PE_STORAGE_ACCOUNT_BLOB_NAME \
     privateEndpoints_storageAccount_fileName=$PE_STORAGE_ACCOUNT_FILE_NAME \





