#!/bin/bash
#
# Only creates resources if they don't already exist
# 
# Provisions
#   Certificates required for P2S VPN tunnel

set -e

DIR="$(cd "$(dirname "$0")" && pwd)"
# Edit env.sh to your preferences
source $DIR/env.sh

echo -e "${PURPLE}---------Certificates-------------${NC}"
# from https://docs.microsoft.com/en-us/azure/storage/files/storage-files-configure-p2s-vpn-linux
# from https://medium.com/@arisplakias/azure-point-to-site-vpn-certificates-with-openssl-406838731a7c
rootCertName="$P2S_PUBLIC_CERT_NAME"
clientCertName="$P2S_CLIENT_CERT_NAME"
# I stupidly use the same password for everything
password="$P2S_CERT_PASSWORD"

mkdir -p certs
cd certs

# Generate CARoot private key 
echo -e "${GREEN}Stage 1${NC}"
if [ ! -f $rootCertName.key ]; then
    openssl genrsa -aes256 \
        -passout pass:$password \
        -out $rootCertName.key 2048 
fi
# Generate a X.509 CARoot certificate valid for 10 years
echo -e "${GREEN}Stage 2${NC}"
if [ ! -f $rootCertName.cer ]; then
    openssl req -x509 -sha256 -new \
        -passin pass:$password \
        -key $rootCertName.key \
        -out $rootCertName.cer \
        -days 3650 \
        -subj "/CN=$rootCertName"
fi
# Upload the X.509 CA cert to Virtual Networks/Manage Certificates/Upload

# Generate a Client key
echo -e "${GREEN}Stage 3${NC}"
if [ ! -f $clientCertName.key ]; then
    openssl genrsa \
        -out $clientCertName.key 2048
fi
# Generate a client certificate request from the generated client key
echo -e "${GREEN}Stage 4${NC}"
if [ ! -f $clientCertName.req ]; then
    openssl req -new \
        -out $clientCertName.req \
        -key $clientCertName.key \
        -subj "/CN=$clientCertName"
fi
# Generate a client certificate from the certificate request and sign it as the CA that you are.
echo -e "${GREEN}Stage 5${NC}"
if [ ! -f $clientCertName.cer ]; then
    openssl x509 -req -sha256 \
        -passin pass:$password \
        -in $clientCertName.req \
        -out $clientCertName.cer \
        -CAkey $rootCertName.key \
        -CA $rootCertName.cer \
        -days 1800 \
        -CAcreateserial -CAserial serial
fi
# Pack key and certificate in a .pfx(pkcs12 format) 
# Windows Certificate Store friendly
echo -e "${GREEN}Stage 6${NC}"
if [ ! -f $clientCertName.pfx ]; then
    openssl pkcs12 -export \
        -passout pass:$password \
        -out $clientCertName.pfx \
        -inkey $clientCertName.key \
        -in $clientCertName.cer \
        -certfile $rootCertName.cer
    echo "Windows users should double click $clientCertName.pfx to install the client certificate"
fi
cd ..

echo -e "${GREEN}Certificates Created${NC}"
