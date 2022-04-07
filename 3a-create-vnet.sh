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
echo -e "${PURPLE}----------------Hub / Spoke VNET----------${NC}"
echo -e "${PURPLE}-------------------SUBNETS----------------${NC}"
az deployment group create --resource-group "$AZURE_RESOURCE_GROUP_VNET" \
     --template-file templates/template-vnet.json \
     --parameters \
     azureRegionPrimary=$AZURE_REGION \
     vnetNetworkHub=$AZURE_VNET_HUB_NETWORK \
     vnetNetworkHubName=$AZURE_VNET_HUB_NAME \
     vnetNetworkSpoke=$AZURE_VNET_SPOKE_NETWORK \
     vnetNetworkSpokeName=$AZURE_VNET_SPOKE_NAME \
     subnetDefaultNetwork=$VNET_SUBNET_DEFAULT_NETWORK \
     subnetDefaultName=$VNET_SUBNET_DEFAULT_NAME \
     subnetDataNetwork=$VNET_SUBNET_DATA_NETWORK \
     subnetDataName=$VNET_SUBNET_DATA_NAME \
     subnetCredentialsNetwork=$VNET_SUBNET_SECRETS_NETWORK \
     subnetCredentialsName=$VNET_SUBNET_SECRETS_NAME \
     subnetBastionNetwork=$VNET_SUBNET_BASTION_NETWORK \
     subnetBastionName=$VNET_SUBNET_BASTION_NAME \
     subnetVngNetwork=$VNET_SUBNET_VNG_NETWORK \
     subnetVngName=$VNET_SUBNET_VNG_NAME \
     lastPublishedAt="$NOW_PUBLISHED_AT" \
     version="$VERSION" \
     project="$PROJECT" \
     subnetDnsAciNetwork=$VNET_SUBNET_DNS_ACI_NETWORK \
#    this won't parse :-(
#     subnetDnsAciName=$VNET_SUBNET_DNS_ACI_NAME \ 

echo -e "${PURPLE}-------------------private DNS groups and VNET links ----------------${NC}"
# create private DNS zones - link those zones to each VNET - for PLEs
az deployment group create --resource-group "$AZURE_RESOURCE_GROUP_VNET" \
     --template-file templates/template-dns-private.json \
     --parameters \
     vnetResourceGroup=$AZURE_RESOURCE_GROUP_VNET \
     vnetNetworkName=$AZURE_VNET_HUB_NAME \
     lastPublishedAt="$NOW_PUBLISHED_AT" \
     version="$VERSION" \
     project="$PROJECT" \

az deployment group create --resource-group "$AZURE_RESOURCE_GROUP_VNET" \
     --template-file templates/template-dns-private.json \
     --parameters \
     vnetResourceGroup=$AZURE_RESOURCE_GROUP_VNET \
     vnetNetworkName=$AZURE_VNET_SPOKE_NAME \
     lastPublishedAt="$NOW_PUBLISHED_AT" \
     version="$VERSION" \
     project="$PROJECT" \

echo -e "${PURPLE}-------------------Deploy DNS Forwarder----------------${NC}"
# https://github.com/dmauser/PrivateLink/tree/master/DNS-Integration-P2S
# https://github.com/whiteducksoftware/az-dns-forwarder
# This command does not support tagging! https://github.com/Azure/azure-cli/issues/5713
acs_result=$(az container create \
  --resource-group "$AZURE_RESOURCE_GROUP_VNET" \
  --name dns-forwarder \
  --image ghcr.io/whiteducksoftware/az-dns-forwarder/az-dns-forwarder:latest \
  --cpu 1 \
  --memory 0.5 \
  --restart-policy always \
  --vnet $AZURE_VNET_HUB_NAME \
  --subnet $VNET_SUBNET_DNS_ACI_NAME \
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
# Apply this IP address as a DNS forwarder on the vnet
az network vnet update \
     --resource-group "$AZURE_RESOURCE_GROUP_VNET" \
     --name "$AZURE_VNET_HUB_NAME" \
     --dns-servers "$acs_ip"
