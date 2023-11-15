#!/bin/bash
INDEX_POLICIES="./config/wazuh_indexer/index-policies"
SNAPSHOTS_CONFIG="./config/wazuh_indexer/snapshots-config"
OUTPUT_FILE="./wazuh-config.json"

# Check if the output file already exists and remove it
if [ -f "$OUTPUT_FILE" ]; then
    rm "$OUTPUT_FILE"
fi

# Function to combine JSON files in a directory and its subdirectories
combine_json_files() {
    local dir="$1"
    find "$dir" -type f -name "*.json" -exec cat {} >> "$OUTPUT_FILE" \; -exec echo >> "$OUTPUT_FILE" \;
}

# Combine JSON files from the directory and its subdirectories
combine_json_files "$INDEX_POLICIES"
combine_json_files "$SNAPSHOTS_CONFIG"

echo "Combined JSON files into $OUTPUT_FILE"
