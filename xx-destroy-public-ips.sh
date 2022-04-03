#!/usr/bin/env bash
#
# You can't purge a Resource Group via Azure portal if there are attached public IPs
# This script retained because it has jq code I don't want to lose
#
# Assumes 
#   azure cli is installed
#   jq is installed
#   default subscription
# Removes
#   Resource gateways, bastion hosts and public IPs
# Leaves 
#   Other resources

set -e
set -u

# Edit env.sh to your preferences
source env.sh

# Public IPs can only be removed after their associations are deleted.  
# The simples way to do that is to remove the associated items before trying to remove the public IPs
echo -e "${PURPLE}-------------- Bastion Host - takes minutes -----------------------${NC}"
bastion_hosts=$(az network bastion list --resource-group $AZURE_RESOURCE_GROUP --query "[].name")
for bastion_host in $(jq -r '.[]' <<< $bastion_hosts); do
    az network bastion delete --name $bastion_host --resource-group $AZURE_RESOURCE_GROUP
    echo "removed $bastion_host"
done

echo -e "${PURPLE}-------------- VNET Gateways - takes minutes -----------------------${NC}"
vnet_gateway_hosts=$(az network vnet-gateway list --resource-group $AZURE_RESOURCE_GROUP --query "[].name")
for vnet_gateway in $(jq -r '.[]' <<< $vnet_gateway_hosts); do
    az network vnet-gateway delete --name $vnet_gateway --resource-group $AZURE_RESOURCE_GROUP
    echo "removed $vnet_gateway"
done

#az network public-ip list --resource-group "$AZURE_RESOURCE_GROUP" 
public_ips=$(az network public-ip list --resource-group "$AZURE_RESOURCE_GROUP" -o json)
public_ip_associations=$(jq -r '.[].ipConfiguration.id' <<< $public_ips)
public_ip_names=$(jq -r '.[].name' <<< $public_ips)

#echo $public_ips
#echo "public_ip_associations: $public_ip_associations"
#echo "public_ip_names: $public_ip_names"

# I deleted the associated resources above because I kNOW_PUBLISHED_AT I don't have any other resouces bound to public IPs
# We could have iterated across the IP associations, figure out which item they are bound to and delete them
echo -e "${PURPLE}-------------- Disassociate Public IP ---------------${NC}"
for ip_association in $public_ip_associations; do
    if [[ "$ip_association" != "null" ]] ; then
        echo "Public IP will fail because of existing association $ip_association"
    fi
done

echo -e "${PURPLE}-------------- Delete Public IP - takes minutes---------------------${NC}"
# use jq -r for raw mode.  Removes double quotes from strings
for public_ip_name in $public_ip_names; do
    az network public-ip delete --name "$public_ip_name" --resource-group "$AZURE_RESOURCE_GROUP"
    echo "removed $public_ip_name"
done

