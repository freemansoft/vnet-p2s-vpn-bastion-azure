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

echo "----------  Storage Endpoints -----------"
az deployment group delete --resource-group "$AZURE_RESOURCE_GROUP" --name template-storage-endpoints
echo "----------  Storage  -----------"
az deployment group delete --resource-group "$AZURE_RESOURCE_GROUP" --name template-storage
echo "----------  VPN and Bastion -----------"
az deployment group delete --resource-group "$AZURE_RESOURCE_GROUP" --name template-bastion-vpn
echo "----------  VNET -----------"
az deployment group delete --resource-group "$AZURE_RESOURCE_GROUP" --name template-vnet
