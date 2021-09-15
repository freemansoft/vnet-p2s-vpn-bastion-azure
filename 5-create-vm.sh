#!/bin/bash
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

echo "This will take several minutes "
echo "-----------------VIRTUAL MACHINES------------------"
az deployment group create --resource-group "$AZURE_RESOURCE_GROUP" \
     --template-file templates/template-vm-simple.json \
     --parameters \
     location="$AZURE_REGION" \
     vnetNetworkName="$AZURE_VNET_NAME" \
     vmSubnetName="$VNET_SUBNET_DEFAULT_NAME"\
     vmName="$VM_NAME" \
     vmAdminUsername="$VM_ADMIN_USERNAME" \
     vmAdminPasswordOrKey="$VM_ADMIN_PASSWORD" \
     vmUbuntuOSVersion="$VM_UBUNTU_OS_VERSION" \
     vmSize="$VM_SIZE" 


