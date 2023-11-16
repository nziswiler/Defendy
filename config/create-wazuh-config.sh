#!/bin/bash

# Set the working directory correctly
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
cd "$SCRIPT_DIR" || exit

USER_CONFIG="./wazuh_indexer/user-config"
SNAPSHOTS_CONFIG="./wazuh_indexer/snapshots-config"
INDEX_POLICIES="./wazuh_indexer/index-policies"

OUTPUT_FILE="../wazuh-config.json"

combine_json_files() {
    local dir="$1"
    find "$dir" -type f -name "*.json" -exec cat {} >> "$OUTPUT_FILE" \; -exec echo >> "$OUTPUT_FILE" \;
}

if [ -f "$OUTPUT_FILE" ]; then
    rm "$OUTPUT_FILE"
fi

# Add timestamp
echo "# Generated on $(date)" > "$OUTPUT_FILE"

combine_json_files "$USER_CONFIG"
combine_json_files "$SNAPSHOTS_CONFIG"
combine_json_files "$INDEX_POLICIES"

echo "Combined JSON files into $OUTPUT_FILE"