#!/bin/bash
# install azure CLI and snap on local machine

DIR="$(cd "$(dirname "$0")" && pwd)"
source $DIR/env.sh

if ! command -v jq &> /dev/null
then
    echo "installing jq with snap"
    if ! sudo snap install jq ; then
        sudo apt install -y jq
    fi
else
    echo "jq already installed"
fi

# assumes azure CLI installed
# should really check the version.  
# As of 3/2022 Ubunutu latest is 2.0.3 but Microsoft latest is 2.34.1
if ! command -v az &> /dev/null
then
    echo "installing Azure CLI"
    curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash 
else
    echo "Azure CLI already installed"
fi
