#!/bin/bash
#
# Attaches the certificates to the VPN Point-to-site configuration
#
# Assumes 
#   azure cli is installed
#   jq is installed
#   default subscription
# Provisions
#   Resource Group
#   User Assigned Identity

set -e

DIR="$(cd "$(dirname "$0")" && pwd)"
# Edit env.sh to your preferences
source $DIR/env.sh

# only creates if missing
source ./create-certs.sh

# This is a CLI for now because that is what I got working
echo -e "${PURPLE}-------- Point to Site VPN -------${NC}"
echo -e "P2S adding address pool NOT YET IMPLEMENTED "
az network vnet-gateway root-cert create \
    --public-cert-data certs/$P2S_PUBLIC_CERT_NAME.cer \
    --gateway-name "$VNGS_VNG_NAME" \
    --name $P2S_PUBLIC_CERT_NAME \
    --resource-group "$AZURE_RESOURCE_GROUP"