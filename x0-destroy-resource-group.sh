#!/usr/bin/env bash
#
# Assumes 
#   azure cli is installed
#   jq is installed
#   default subscription
# Removes
#   Resource Group and all associates resources
#
# The purge scripts delete by template which handles the public IPs correctly.
# set -e

# Edit env.sh to your preferences
source env.sh

echo "This will fail if you have public IPs that are still bound to a resource."
az group delete --yes --resource-group "$AZURE_RESOURCE_GROUP_SPOKE_APP"
az group delete --yes --resource-group "$AZURE_RESOURCE_GROUP_SPOKE_PERSIST"
az group delete --yes --resource-group "$AZURE_RESOURCE_GROUP_HUB_BASTION"
az group delete --yes --resource-group "$AZURE_RESOURCE_GROUP_SPOKE_SECRETS"
az group delete --yes --resource-group "$AZURE_RESOURCE_GROUP_VNET"
