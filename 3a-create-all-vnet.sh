#!/usr/bin/env bash
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
echo -e "${PURPLE}----------------Hub VNET / Subnets----------${NC}"
az deployment group create --resource-group "$AZURE_RESOURCE_GROUP_HUB_VNET" \
     --template-file templates/template-vnet-hub.json \
     --parameters \
     azureRegionPrimary=$AZURE_REGION \
     vnetNetworkHub="$AZURE_VNET_HUB_NETWORK" \
     vnetNetworkHubName="$AZURE_VNET_HUB_NAME" \
     subnetHubBastionNetwork="$VNET_HUB_SUBNET_BASTION_NETWORK" \
     subnetHubBastionName="$VNET_HUB_SUBNET_BASTION_NAME" \
     subnetHubVngNetwork="$VNET_HUB_SUBNET_VNG_NETWORK" \
     subnetHubVngName="$VNET_HUB_SUBNET_VNG_NAME" \
     subnetHubShellAciName="$VNET_HUB_SUBNET_SHELL_ACI_NAME" \
     subnetHubShellAciNetwork="$VNET_HUB_SUBNET_SHELL_ACI_NETWORK" \
     subnetHubStorageName="$VNET_HUB_SUBNET_STORAGE_NAME" \
     subnetHubStorageNetwork="$VNET_HUB_SUBNET_STORAGE_NETWORK" \
     lastPublishedAt="$NOW_PUBLISHED_AT" \
     version="$VERSION" \
     project="$PROJECT" \
     subnetHubDnsAciNetwork="$VNET_HUB_SUBNET_DNS_ACI_NETWORK" \
     subnetHubDnsAciName="$VNET_HUB_SUBNET_DNS_ACI_NAME" 

echo -e "${PURPLE}-------------------Spoke VNET / subnets ----------------${NC}"
az deployment group create --resource-group "$AZURE_RESOURCE_GROUP_SPOKE_VNET" \
     --template-file templates/template-vnet-spoke.json \
     --parameters \
     azureRegionPrimary=$AZURE_REGION \
     vnetNetworkSpoke="$AZURE_VNET_SPOKE_NETWORK" \
     vnetNetworkSpokeName="$AZURE_VNET_SPOKE_NAME" \
     subnetSpokeDefaultNetwork="$VNET_SPOKE_SUBNET_DEFAULT_NETWORK" \
     subnetSpokeDefaultName="$VNET_SPOKE_SUBNET_DEFAULT_NAME" \
     subnetSpokeDataNetwork="$VNET_SPOKE_SUBNET_STORAGE_NETWORK" \
     subnetStorageName="$VNET_SPOKE_SUBNET_STORAGE_NAME" \
     subnetSpokeCredentialsNetwork="$VNET_SPOKE_SUBNET_SECRETS_NETWORK" \
     subnetSpokeCredentialsName="$VNET_SPOKE_SUBNET_SECRETS_NAME" \
     lastPublishedAt="$NOW_PUBLISHED_AT" \
     version="$VERSION" \
     project="$PROJECT" 

###
# peering must be configured in both directions to make it work
###

echo -e "${PURPLE}-------------------Peer Spoke to Hub ----------------${NC}"
az deployment group create --resource-group "$AZURE_RESOURCE_GROUP_SPOKE_VNET" \
     --template-file templates/template-vnet-peer.json \
     --parameters \
     vnetThisName="$AZURE_VNET_SPOKE_NAME" \
     vnetThatRG="$AZURE_RESOURCE_GROUP_HUB_VNET" \
     vnetThat="$AZURE_VNET_HUB_NETWORK" \
     vnetThatName="$AZURE_VNET_HUB_NAME" \

echo -e "${PURPLE}-------------------Peer Hub to Spoke ----------------${NC}"
# has to be done with the RG of the spoke and pass in the RG of the remote hub
az deployment group create --resource-group "$AZURE_RESOURCE_GROUP_HUB_VNET" \
     --template-file templates/template-vnet-peer.json \
     --parameters \
     vnetThisName="$AZURE_VNET_HUB_NAME" \
     vnetThatRG="$AZURE_RESOURCE_GROUP_SPOKE_VNET" \
     vnetThat="$AZURE_VNET_SPOKE_NETWORK" \
     vnetThatName="$AZURE_VNET_SPOKE_NAME" \

echo -e "${PURPLE}-------------------private DNS groups and VNET links (HUB)----------------${NC}"
# create private DNS zones - link private DNS zones to hub and spoke VNETs - for PLEs
# zones are same if have same name in same resource group
az deployment group create --resource-group "$AZURE_RESOURCE_GROUP_HUB_VNET" \
     --template-file templates/template-dns-private.json \
     --parameters \
     vnetResourceGroup="$AZURE_RESOURCE_GROUP_HUB_VNET" \
     vnetNetworkName="$AZURE_VNET_HUB_NAME" \
     lastPublishedAt="$NOW_PUBLISHED_AT" \
     version="$VERSION" \
     project="$PROJECT" \

echo -e "${PURPLE}-------------------private DNS groups and VNET links (SPOKE)----------------${NC}"
az deployment group create --resource-group "$AZURE_RESOURCE_GROUP_SPOKE_VNET" \
     --template-file templates/template-dns-private.json \
     --parameters \
     vnetResourceGroup="$AZURE_RESOURCE_GROUP_SPOKE_VNET" \
     vnetNetworkName="$AZURE_VNET_SPOKE_NAME" \
     lastPublishedAt="$NOW_PUBLISHED_AT" \
     version="$VERSION" \
     project="$PROJECT" \

echo -e "${PURPLE}-------------------Deploy DNS Forwarder----------------${NC}"
# https://github.com/dmauser/PrivateLink/tree/master/DNS-Integration-P2S
# https://github.com/whiteducksoftware/az-dns-forwarder
# This command does not support tagging! https://github.com/Azure/azure-cli/issues/5713
# Deploy the DNS Forwarder as ACI
acs_result=$(az container create \
  --resource-group "$AZURE_RESOURCE_GROUP_HUB_VNET" \
  --name dns-forwarder \
  --image ghcr.io/whiteducksoftware/az-dns-forwarder/az-dns-forwarder:latest \
  --cpu 1 \
  --memory 0.5 \
  --restart-policy always \
  --vnet "$AZURE_VNET_HUB_NAME" \
  --subnet "$VNET_HUB_SUBNET_DNS_ACI_NAME" \
  --ip-address private \
  --location $AZURE_REGION \
  --os-type Linux \
  --port 53 \
  --protocol UDP)

#echo $acs_result

# extract the id from the result
acs_id=$(jq -r ".id" <<< "$acs_result" )
# apply the tags - sync these with the templates
az resource tag \
     --is-incremental \
     --ids $acs_id \
     --tags "PublishedAt=$NOW_PUBLISHED_AT" "Project=$PROJECT" "Version=$VERSION"

  
# extract the IP from the result
acs_ip=$(jq -r ".ipAddress.ip" <<< "$acs_result" )
echo "DNS Forwarder IP is $acs_ip"

echo -e "${PURPLE}-------------------Add DNS Forwarder to VNet----------------${NC}"
# Apply this DNS Forwarder IP address as a DNS forwarder on the vnet
az network vnet update \
     --resource-group "$AZURE_RESOURCE_GROUP_HUB_VNET" \
     --name "$AZURE_VNET_HUB_NAME" \
     --dns-servers "$acs_ip"
