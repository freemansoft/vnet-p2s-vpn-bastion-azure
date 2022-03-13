#!/bin/bash
#
# THIS SCRIPT IS USELESS.  It deletes the templates and not the resources
#
# Assumes 
#   azure cli is installed
#   jq is installed
#   default subscription
# Deprovisions
#   The templates
set -e

# Edit env.sh to your preferences
DIR="$(cd "$(dirname "$0")" && pwd)"
source $DIR/env.sh

echo -e "${PURPLE}----------  Storage Endpoints -----------${NC}"
az deployment group delete --resource-group "$AZURE_RESOURCE_GROUP" --name template-storage-endpoints
echo -e "${PURPLE}----------  Storage  -----------${NC}"
az deployment group delete --resource-group "$AZURE_RESOURCE_GROUP" --name template-storage
echo -e "${PURPLE}----------  VPN and Bastion -----------${NC}"
az deployment group delete --resource-group "$AZURE_RESOURCE_GROUP" --name template-bastion-vpn
echo -e "${PURPLE}----------  VNET -----------${NC}"
az deployment group delete --resource-group "$AZURE_RESOURCE_GROUP" --name template-vnet
