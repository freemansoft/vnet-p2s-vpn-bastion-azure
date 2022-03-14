#!/bin/bash
#
# This is not functinal yet.  It does not add the address pool
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

echo -e "${PURPLE}-------- Point to Site VPN -------${NC}"
echo -e "P2S adding address pool NOT YET IMPLEMENTED "
