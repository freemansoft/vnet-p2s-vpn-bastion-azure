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

echo "removing everything in $AZURE_RESOURCE_GROUP via empty template"
# rely on the "Complete" mode with an empty template.  It should remove all resources
az deployment group create -g $AZURE_RESOURCE_GROUP --template-file templates/template-empty.json --mode Complete

