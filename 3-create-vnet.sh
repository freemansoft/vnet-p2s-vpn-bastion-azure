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
echo -e "${PURPLE}--------------------VNET------------------${NC}"
echo -e "${PURPLE}-------------------SUBNETS----------------${NC}"
az deployment group create --resource-group "$AZURE_RESOURCE_GROUP_VNET" \
     --template-file templates/template-vnet.json \
     --parameters \
     azureRegionPrimary=$AZURE_REGION \
     vnetNetwork=$AZURE_VNET_NETWORK \
     vnetNetworkName=$AZURE_VNET_NAME \
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
     subnetAciNetwork=$VNET_SUBNET_ACI_NETWORK \
#    this won't parse :-(
#     subnetAciName=$VNET_SUBNET_ACI_NAME \ 


echo -e "${PURPLE}-------------------Deploy DNS Forwarder----------------${NC}"
# https://github.com/dmauser/PrivateLink/tree/master/DNS-Integration-P2S
# https://github.com/whiteducksoftware/az-dns-forwarder
acs_result=$(az container create \
  --resource-group "$AZURE_RESOURCE_GROUP_VNET" \
  --name dns-forwarder \
  --image ghcr.io/whiteducksoftware/az-dns-forwarder/az-dns-forwarder:latest \
  --cpu 1 \
  --memory 0.5 \
  --restart-policy always \
  --vnet $AZURE_VNET_NAME \
  --subnet $VNET_SUBNET_ACI_NAME \
  --ip-address private \
  --location $AZURE_REGION \
  --os-type Linux \
  --port 53 \
  --protocol UDP)

#echo $acs_result
  
# extract the IP from the result
acs_ip=$(jq -r ".ipAddress.ip" <<< "$acs_result" )
echo "DNS Forwarder IP is $acs_ip"

echo -e "${PURPLE}-------------------Add DNS Forwarder to VNet----------------${NC}"
# Apply this IP address as a DNS forwarder on the vnet
az network vnet update \
     --resource-group "$AZURE_RESOURCE_GROUP_VNET" \
     --name "$AZURE_VNET_NAME" \
     --dns-servers "$acs_ip"
