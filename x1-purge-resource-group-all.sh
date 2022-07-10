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

echo "removing everything in $AZURE_RESOURCE_GROUP $AZURE_RESOURCE_GROUP_SPOKE_PERSIST $AZURE_RESOURCE_GROUP_HUB_BASTION $AZURE_RESOURCE_GROUP_HUB_VNET"
bash $DIR/x2-purge-resource-group-bastion.sh
bash $DIR/x2-purge-resource-group-ephemeral.sh
bash $DIR/x2-purge-resource-group-persist-spoke.sh
bash $DIR/x2-purge-resource-group-persist-hub.sh
bash $DIR/x2-purge-resource-group-keyvault.sh
bash $DIR/x2-purge-resource-group-vnet.sh
