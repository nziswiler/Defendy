#!/bin/bash

# Set the working directory correctly
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
cd "$SCRIPT_DIR" || exit

if [ -d "./config/wazuh_indexer_ssl_certs" ]; then
    rm -rf ./config/wazuh_indexer_ssl_certs
fi

sysctl -w vm.max_map_count=262144

# Run Docker Compose for certificate generation
docker compose -f generate-indexer-certs.yml run --rm generator

# Startup defendy
docker compose up -d

# Generate the Wazuh-Config
./config/create-wazuh-config.sh

# Generating Linux Agent installation script
./config/wazuh-agent/linux/generate-linux-agent-installer.sh