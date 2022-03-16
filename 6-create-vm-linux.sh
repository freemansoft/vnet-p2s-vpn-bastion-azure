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

echo -e "${PURPLE}-----------------VIRTUAL MACHINES------------------${NC}"
echo "This will take several minutes "
create_results_metadata=$(az deployment group create --resource-group "$AZURE_RESOURCE_GROUP" \
     --template-file templates/template-vm-linux.json \
     --parameters \
     vnetNetworkName="$AZURE_VNET_NAME" \
     subnetVmName="$VNET_SUBNET_DEFAULT_NAME"\
     vmName="$VM_UBUNTU_NAME" \
     vmAdminUsername="$VM_UBUNTU_USERNAME" \
     vmAdminPasswordOrKey="$VM_UBUNTU_PASSWORD" \
     vmUbuntuOSVersion="$VM_UBUNTU_OS_VERSION" \
     vmSize="$VM_SIZE" \
    lastPublishedAt="$NOW_PUBLISHED_AT" \
    version="$VERSION" \
    project="$PROJECT" \
     )

# echo $create_results_metadata

vm_resource_id=$(jq -r ".properties.outputs.vmResourceId.value" <<< "$create_results_metadata")
echo "Created vm $vm_resource_id"

echo -e "${PURPLE}---------------- LOG ANALYTICS WORKSPACE----------------------${NC}"
# Use "list" so we don't have to handle errors. Returns [] if it isn't there - returns [value] if it exists
monitor_list_results=$(az monitor log-analytics workspace list --resource-group $AZURE_RESOURCE_GROUP --query "[?name=='$LOG_ANALYTICS_WORKSPACE_NAME'].customerId")
if [ "[]" == "$vms_metadata" ]; then
     echo "No Log Analytics Workspace found. Skipping VM Agent"
else
     workspace_id=$(jq -r ".[0]" <<< "$monitor_list_results")
     # .customerId is is the WorkspaceId .id is the full path
     # workspace_id=$(az monitor log-analytics workspace show           --resource-group $AZURE_RESOURCE_GROUP --workspace-name $LOG_ANALYTICS_WORKSPACE_NAME --query customerId)
     # .primarySharedKey and .secondarySharedKey
     shared_keys=$(az monitor log-analytics workspace get-shared-keys --resource-group $AZURE_RESOURCE_GROUP --workspace-name $LOG_ANALYTICS_WORKSPACE_NAME)
     primary_key=$(jq -r  ".primarySharedKey" <<< "$shared_keys")

     echo -e "${PURPLE}----------------MANAGEMENT EXTENSIONS----------------------${NC}"
     az deployment group create --resource-group "$AZURE_RESOURCE_GROUP" \
          --template-file templates/template-vm-linux-extensions.json \
          --parameters \
          vmName="$VM_UBUNTU_NAME" \
          logAnalyticsWorkspaceId="$workspace_id" \
          logAnalyticsWorkspaceKey="$primary_key" \
          lastPublishedAt="$NOW_PUBLISHED_AT" \
          version="$VERSION" \
          project="$PROJECT" \
     # TODO capture the results and just log a single line
fi
