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

echo -e "${PURPLE}--------------Key Vault-------------${NC}"
az deployment group create --resource-group "$AZURE_RESOURCE_GROUP_SECRETS" \
    --template-file templates/template-keyvault.json \
    --parameters \
    azureRegionPrimary=$AZURE_REGION \
    vnetResourceGroup=$AZURE_RESOURCE_GROUP_VNET \
    vnetNetworkName=$AZURE_VNET_NAME \
    subnetCredentialsName="$VNET_SUBNET_SECRETS_NAME" \
    keyVaultName="$KEY_VAULT_NAME-2" \
    lastPublishedAt="$NOW_PUBLISHED_AT" \
    version="$VERSION" \
    project="$PROJECT" \

echo -e "${PURPLE}--------------Key Vault Private Link-------------${NC}"
az deployment group create --resource-group "$AZURE_RESOURCE_GROUP_SECRETS" \
    --template-file templates/template-keyvault-endpoints.json \
    --parameters \
    azureRegionPrimary=$AZURE_REGION \
    vnetResourceGroup=$AZURE_RESOURCE_GROUP_VNET \
    vnetNetworkName=$AZURE_VNET_NAME \
    subnetCredentialsName="$VNET_SUBNET_SECRETS_NAME" \
    keyVaultName="$KEY_VAULT_NAME" \
    privateEndpointsKeyVaultName="$KEY_VAULT_PE_NAME" \
    lastPublishedAt="$NOW_PUBLISHED_AT" \
    version="$VERSION" \
    project="$PROJECT" \
