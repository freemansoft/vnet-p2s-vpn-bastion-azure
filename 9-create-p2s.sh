#!/bin/bash
#
# Assumes 
#   azure cli is installed
#   jq is installed
#   default subscription
# Provisions
#   Resource Group
#   User Assigned Identity

# Edit env.sh to your preferences
DIR="$(cd "$(dirname "$0")" && pwd)"
source $DIR/env.sh

echo -e "${PURPLE}---------Certificates-------------${NC}"
echo -e "${PURPLE}-------- Point to Site VPN -------${NC}"

echo "NOT YET IMPLEMENTED - have to create certs prior to creation"
