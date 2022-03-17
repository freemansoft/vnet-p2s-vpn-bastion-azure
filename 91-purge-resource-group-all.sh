#!/bin/bash
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

echo "removing everything in $AZURE_RESOURCE_GROUP $AZURE_RESOURCE_GROUP_PERSIST $AZURE_RESOURCE_GROUP_VNG $AZURE_RESOURCE_GROUP_BASTION $AZURE_RESOURCE_GROUP_VNET"
bash $DIR/92-purge-resource-group-bastion.sh
bash $DIR/92-purge-resource-group-vng.sh
bash $DIR/92-purge-resource-group-ephemeral.sh
bash $DIR/92-purge-resource-group-persist.sh
bash $DIR/92-purge-resource-group-vnet.sh
