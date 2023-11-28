#!/bin/bash
# Set the working directory correctly
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
cd "$SCRIPT_DIR" || exit

source ../../../.env
SCRIPT_NAME="../../../output/install-linux-agent.sh"
PACKETBEAT_YAML="https://raw.githubusercontent.com/nziswiler/Defendy/main/config/wazuh_agent/linux/packetbeat.yml"

cat > "$SCRIPT_NAME" <<EOF
#!/bin/bash

WAZUH_MANAGER_PORT='$WAZUH_AGENT_CONNECTION_PORT'
WAZUH_REGISTRATION_PORT='$WAZUH_AGENT_ENROLLMENT_PORT'

if [ -f "/etc/redhat-release" ]; then
    wget https://packages.wazuh.com/4.x/yum/pool/main/w/wazuh-agent/wazuh-agent_4.6.0-1.x86_64.rpm && sudo WAZUH_MANAGER='$SERVER' WAZUH_MANAGER_PORT='$WAZUH_AGENT_CONNECTION_PORT' WAZUH_REGISTRATION_PORT='$WAZUH_AGENT_ENROLLMENT_PORT' WAZUH_AGENT_GROUP='Linux'  rpm -ivh wazuh-agent_4.6.0-1.x86_64.rpm
    curl -L -O https://artifacts.elastic.co/downloads/beats/packetbeat/packetbeat-8.11.1-x86_64.rpm && sudo rpm -vi packetbeat-8.11.1-x86_64.rpm
elif [ -f "/etc/debian_version" ]; then
    wget https://packages.wazuh.com/4.x/apt/pool/main/w/wazuh-agent/wazuh-agent_4.6.0-1_amd64.deb && sudo WAZUH_MANAGER='$SERVER' WAZUH_MANAGER_PORT='$WAZUH_AGENT_CONNECTION_PORT' WAZUH_REGISTRATION_PORT='$WAZUH_AGENT_ENROLLMENT_PORT' WAZUH_AGENT_GROUP='Linux' dpkg -i wazuh-agent_4.6.0-1_amd64.deb
    curl -L -O https://artifacts.elastic.co/downloads/beats/packetbeat/packetbeat-8.11.1-amd64.deb && sudo dpkg -i packetbeat-8.11.1-amd64.deb
else
    echo "Unknown distribution or unsupported package type."
    exit 1
fi
sudo systemctl daemon-reload
sudo systemctl enable wazuh-agent
sudo systemctl start wazuh-agent

sudo wget ${PACKETBEAT_YAML} -O /etc/packetbeat/packetbeat.yml
sudo service packetbeat restart
EOF

chmod +x "$SCRIPT_NAME"
echo "Generated $SCRIPT_NAME script."
