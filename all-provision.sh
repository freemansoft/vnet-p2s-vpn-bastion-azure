#!/usr/bin/env bash
#
# Provision everything
# Does NOT install tools or login to Azure

set -e
source env.sh

# I tend to create everything and the purge the bastion if I'm not going to use it

echo -e "${GREEN}Creating Resource Group ${NC}"
./2-create-all-resources.sh
echo -e "${GREEN}Creating VNet ${NC}"
./3a-create-all-vnet.sh
echo -e "${GREEN}Creating Key Vault ${NC}"
./4a-create-spoke-keyvault.sh
echo -e "${GREEN}Creating Storage ${NC}"
./5a-create-spoke-storage.sh
echo -e "${GREEN}Creating Cosmos DB ${NC}"
./5b-create-spoke-cosmosdb.sh
echo -e "${GREEN}Creating Monitoring ${NC}"
./6a-create-spoke-monitor.sh
echo -e "${GREEN}Creating Linux VM ${NC}"
./6b-create-spoke-vm-linux.sh
# echo -e "${GREEN}Creating Bastion ${NC}"
# ./7a-create-hub-bastion.sh
# echo -e "${GREEN}Creating VPN Gateway ${NC}"
# ./8a-create-hub-vng-with-p2s.sh
