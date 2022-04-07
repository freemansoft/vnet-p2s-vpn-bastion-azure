#!/usr/bin/env bash
#
# Provision everything
# Does NOT install tools or login to Azure

set -e
source env.sh

# I tend to create everything and the purge the bastion if I'm not going to use it

echo -e "${GREEN}Creating Resource Group ${NC}"
./2-create-resources.sh
echo -e "${GREEN}Creating VNet ${NC}"
./3a-create-vnet.sh
echo -e "${GREEN}Creating Key Vault ${NC}"
./4a-create-keyvault.sh
echo -e "${GREEN}Creating Storage ${NC}"
./5a-create-storage.sh
echo -e "${GREEN}Creating Cosmos DB ${NC}"
./5b-create-cosmosdb.sh
echo -e "${GREEN}Creating Monitoring ${NC}"
./6a-create-monitor.sh
echo -e "${GREEN}Creating Linux VM ${NC}"
./6b-create-vm-linux.sh
# echo -e "${GREEN}Creating Bastion ${NC}"
# ./7-create-bastion.sh
# echo -e "${GREEN}Creating VPN Gateway ${NC}"
# ./8-create-vng-with-p2s.sh
