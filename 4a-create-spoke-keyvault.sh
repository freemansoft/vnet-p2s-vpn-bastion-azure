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

echo -e "${PURPLE}--------------Key Vault-------------${NC}"
az deployment group create --resource-group "$AZURE_RESOURCE_GROUP_SPOKE_SECRETS" \
    --template-file templates/template-keyvault.json \
    --parameters \
    azureRegionPrimary=$AZURE_REGION \
    vnetResourceGroup="$AZURE_RESOURCE_GROUP_HUB_VNET" \
    vnetNetworkName="$AZURE_VNET_SPOKE_NAME" \
    subnetSpokeCredentialsName="$VNET_SPOKE_SUBNET_SECRETS_NAME" \
    keyVaultName="$SPOKE_KEY_VAULT_NAME" \
    lastPublishedAt="$NOW_PUBLISHED_AT" \
    version="$VERSION" \
    project="$PROJECT" \

echo -e "${PURPLE}--------------Key Vault Private Link-------------${NC}"
az deployment group create --resource-group "$AZURE_RESOURCE_GROUP_SPOKE_SECRETS" \
    --template-file templates/template-keyvault-endpoints.json \
    --parameters \
    azureRegionPrimary=$AZURE_REGION \
    vnetResourceGroup="$AZURE_RESOURCE_GROUP_HUB_VNET" \
    vnetNetworkName="$AZURE_VNET_SPOKE_NAME" \
    subnetSpokeCredentialsName="$VNET_SPOKE_SUBNET_SECRETS_NAME" \
    keyVaultName="$SPOKE_KEY_VAULT_NAME" \
    privateEndpointsKeyVaultName="$SPOKE_KEY_VAULT_PE_NAME" \
    lastPublishedAt="$NOW_PUBLISHED_AT" \
    version="$VERSION" \
    project="$PROJECT" \
