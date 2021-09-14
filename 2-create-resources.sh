#!/bin/bash
#
# Assumes 
#   azure cli is installed
#   jq is installed
#   default subscription
# Provisions
#   Resource Group

# Edit env.sh to your preferences
DIR="$(cd "$(dirname "$0")" && pwd)"
source $DIR/env.sh

echo "---------RESOURCE GROUP-------------------"
# TODO: add the region to this query!
rg_exists=$(az group exists --resource-group "$AZURE_RESOURCE_GROUP")
if [ "false" = "$rg_exists" ]; then 
    echo "creating resource group : $AZURE_RESOURCE_GROUP"
    # should we capture the output of this? would we lose error messages?
    az group create --name "$AZURE_RESOURCE_GROUP" -l "$AZURE_REGION"
else
    echo "resource group exists: $AZURE_RESOURCE_GROUP"
fi
rg_metadata=$(az group list --query "[?name=='$AZURE_RESOURCE_GROUP']")
echo "using resource group: $rg_metadata"





