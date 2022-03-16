#!/bin/bash
#
# Assumes 
#   azure cli is installed
#   jq is installed
#   default subscription
# Removes
#   Resource Group and all associates resources
#
# Public address associations must be deleted so IP addresses can be deleted
# The purge scripts delete by template which handles the public IPs correctly.
set -e

# Edit env.sh to your preferences
source env.sh

echo "This will fail if you have public IPs that are still bound to a resource."
az group delete --resource-group $AZURE_RESOURCE_GROUP
az group delete --resource-group $AZURE_RESOURCE_GROUP_VNET