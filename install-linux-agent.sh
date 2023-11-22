#!/bin/bash

WAZUH_MANAGER_PORT='30000'
WAZUH_REGISTRATION_PORT='30001'

if [ -f "/etc/redhat-release" ]; then
    wget https://packages.wazuh.com/4.x/yum/pool/main/w/wazuh-agent/wazuh-agent_4.6.0-1.x86_64.rpm && sudo WAZUH_MANAGER='172.162.243.188' WAZUH_MANAGER_PORT='30000' WAZUH_REGISTRATION_PORT='30001' WAZUH_AGENT_GROUP='Linux'  rpm -ivh wazuh-agent_4.6.0-1.x86_64.rpm
    sudo systemctl daemon-reload
    sudo systemctl enable wazuh-agent
    sudo systemctl start wazuh-agent
    curl -LO https://raw.githubusercontent.com/nziswiler/Defendy/main/config/wazuh-agent/linux/packetbeat.yml && sudo rpm -vi packetbeat-8.11.1-x86_64.rpm
    sudo service packetbeat restart
elif [ -f "/etc/debian_version" ]; then
    wget https://packages.wazuh.com/4.x/apt/pool/main/w/wazuh-agent/wazuh-agent_4.6.0-1_amd64.deb && sudo WAZUH_MANAGER='172.162.243.188' WAZUH_MANAGER_PORT='30000' WAZUH_REGISTRATION_PORT='30001' WAZUH_AGENT_GROUP='Linux' dpkg -i wazuh-agent_4.6.0-1_amd64.deb
    sudo systemctl daemon-reload
    sudo systemctl enable wazuh-agent
    sudo systemctl start wazuh-agent
    curl -LO https://raw.githubusercontent.com/nziswiler/Defendy/main/config/wazuh-agent/linux/packetbeat.yml && sudo dpkg -i packetbeat-8.11.1-amd64.deb
    sudo service packetbeat restart
else
    echo "Unknown distribution or unsupported package type."
    exit 1
fi
