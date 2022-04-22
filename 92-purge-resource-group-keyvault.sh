#!/usr/bin/env bash
#
# Assumes 
#   azure cli is installed
#   jq is installed
#   default subscription
# Deprovisions
#   Everything in the resource group
set -e

# Edit env.sh to your preferences
DIR="$(cd "$(dirname "$0")" && pwd)"
source $DIR/env.sh

# echo "removing everything in $AZURE_RESOURCE_GROUP_SECRETS via empty template"
# # Rely on the "complete" mode with an empty template.  It should remove all resources
# az deployment group create -g $AZURE_RESOURCEAZURE_RESOURCE_GROUP_SECRETS_GROUP_VNET --template-file templates/template-empty.json --mode Complete

echo "removing everything in $AZURE_RESOURCE_GROUP_SECRETS except the keyvault itself"
# Rely on the "complete" task with just the vnet template to clear everything other than the vnet

echo -e "${PURPLE}--------------Key Vault-------------${NC}"
az deployment group create \
    --mode complete \
    --resource-group "$AZURE_RESOURCE_GROUP_SECRETS" \
    --template-file templates/template-keyvault.json \
    --parameters \
    azureRegionPrimary=$AZURE_REGION \
    vnetResourceGroup="$AZURE_RESOURCE_GROUP_VNET" \
    vnetNetworkName="$AZURE_VNET_SPOKE_NAME" \
    subnetSpokeCredentialsName="$VNET_SPOKE_SUBNET_SECRETS_NAME" \
    keyVaultName="$KEY_VAULT_NAME" \
    lastPublishedAt="$NOW_PUBLISHED_AT" \
    version="$VERSION" \
    project="$PROJECT" \


