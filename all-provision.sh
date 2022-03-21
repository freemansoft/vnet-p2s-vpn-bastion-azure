#!/bin/bash
#
# Provision everything
# Does NOT install tools or login to Azure

set -e
source env.sh

# I tend to create everything and the purge the bastion if I'm not going to use it

echo -e "${GREEN}Creating Resource Group ${NC}"
./2-create-resources.sh
echo -e "${GREEN}Creating VNet ${NC}"
./3-create-vnet.sh
echo -e "${GREEN}Creating Key Vault ${NC}"
./3b-create-keyvault.sh
echo -e "${GREEN}Creating Storage ${NC}"
./4-create-storage.sh
echo -e "${GREEN}Creating Monitoring ${NC}"
./5-create-monitor.sh
echo -e "${GREEN}Creating Linux VM ${NC}"
./6-create-vm-linux.sh
echo -e "${GREEN}Creating Bastion ${NC}"
./7-create-bastion.sh
echo -e "${GREEN}Creating VPN Gateway ${NC}"
./8-create-vng-with-p2s.sh
