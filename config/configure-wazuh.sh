#!/bin/bash

# Check if the environment is configured correctly and the wazuh api is up and running

# Check if the .env file exists
if [ -f ../.env ]; then
    # Load variables from the .env file
    source ../.env
    
    WAZUH_API="https://$SERVER:$WAZUH_API_PORT"

    # Check if Wazuh API is up and running - retry until it is running
    MAX_RETRIES=10
    RETRY_INTERVAL=5

    retries=0

    while [ $retries -lt $MAX_RETRIES ]; do
        echo "Attempting to reach Wazuh API (Attempt $((retries+1)))..."
        
        # Perform a GET request with a 30-second timeout
        response_code=$(curl -s -o /dev/null -w "%{http_code}" -X GET -k -m 30 "$WAZUH_API/")
        
        if [ "$response_code" = "401" ]; then
            echo "Wazuh API seems to be available."
            exit 0  # Exit successfully since the API is available
        else
            echo "Wazuh API is not reachable yet. HTTP status code: $response_code"
            retries=$((retries+1))
            if [ $retries -eq $MAX_RETRIES ]; then
                echo "Maximum retries reached. Unable to reach the Wazuh API."
                exit 1
            fi
            echo "Retrying in $RETRY_INTERVAL seconds..."
            sleep $RETRY_INTERVAL
        fi
    done
else
    echo ".env file not found."
    exit 1
fi


# Connect to Wazuh API
# Based on the official Wazuh Documentation: https://documentation.wazuh.com/current/user-manual/api/getting-started.html

# Attempt to authenticate and get the token
echo -e "\n- Getting token...\n"
TOKEN=$(curl -s -u "$API_USERNAME:$API_PASSWORD" -k -X POST "$WAZUH_API/security/user/authenticate?raw=true")

# Check if the token is not empty or doesn't contain an error message
if [[ -n "$TOKEN" && "$TOKEN" != *"error"* ]]; then
    echo "Authentication successful. Token obtained: $TOKEN"
    echo -e "\n- Making API calls with TOKEN environment variable ...\n"
    echo -e "Getting default information:\n"
else
    echo "Authentication failed or unable to obtain the token. Check your credentials or Wazuh API endpoint."
    exit 1
fi

