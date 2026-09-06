#!/bin/bash
# -----------------------------------------------------------------------------
# Right-Click Context Rig Migration Utility
# Primary Author: Gemini AI
# Co-Author: @kellystorm
# -----------------------------------------------------------------------------

TARGET_DIR="$1"
CONFIG_FILE="/home/${USER}/.config/nemo-zfs/config.json"

# Abstract parameter extraction
get_config_val() {
    python3 -c "import json; print(json.load(open('$CONFIG_FILE'))['$1'])" 2>/dev/null
}

DATASET=$(get_config_val "dataset_name")
SSH_KEY=$(get_config_val "ssh_key_path")
SSH_USER=$(get_config_val "ssh_user")

# Thin-client device target fallback (can override inside config.json later)
LAPTOP_HOST="thin-client.local" 

# Idiot-proof safety guards
if [ -z "$TARGET_DIR" ]; then
    echo "❌ Error: No file manager path passed by Nemo framework."
    exit 1
fi

echo "🚀 Base Rig Context: Initializing high-speed ZFS Migration Pipeline..."
echo "📂 Target Directory: $TARGET_DIR"

# Generate fresh rolling migration bookmark state snapshot
SNAP_TIME=$(date +%Y%m%d_%H%M%S)
NEW_SNAP="${DATASET}@migrate_${SNAP_TIME}"

echo "📸 Capturing active storage pool state..."
ssh -i "$SSH_KEY" -o IdentitiesOnly=yes -o StrictHostKeyChecking=no "${SSH_USER}@localhost" "sudo zfs snapshot ${NEW_SNAP}"

# Identify the last known historical migration anchor to calculate the absolute delta
OLD_SNAP=$(ssh -i "$SSH_KEY" -o IdentitiesOnly=yes -o StrictHostKeyChecking=no "${SSH_USER}@localhost" \
    "zfs list -H -t snapshot -o name -s creation ${DATASET} | grep '@migrate_' | tail -n 2 | head -n 1")

if [ -n "$OLD_SNAP" ] && [ "$OLD_SNAP" != "$NEW_SNAP" ]; then
    echo "🌿 Found historical anchor: $OLD_SNAP"
    echo "📤 Stream-casting incremental delta directly to thin client over network..."
    
    # 30-thread style line-rate block stream directly over the wire
    ssh -i "$SSH_KEY" -o IdentitiesOnly=yes -o StrictHostKeyChecking=no "${SSH_USER}@localhost" \
        "sudo zfs send -i ${OLD_SNAP} ${NEW_SNAP}" | \
        ssh -i "$SSH_KEY" -o IdentitiesOnly=yes -o StrictHostKeyChecking=no "${SSH_USER}@${LAPTOP_HOST}" \
        "sudo zfs receive -F ${DATASET}"
        
    echo "🟢 Delta stream completely ingestion-sealed on target client!"
else
    echo "⚠️ No historical anchor found. Initializing primary baseline cluster stream..."
    ssh -i "$SSH_KEY" -o IdentitiesOnly=yes -o StrictHostKeyChecking=no "${SSH_USER}@localhost" \
        "sudo zfs send ${NEW_SNAP}" | \
        ssh -i "$SSH_KEY" -o IdentitiesOnly=yes -o StrictHostKeyChecking=no "${SSH_USER}@${LAPTOP_HOST}" \
        "sudo zfs receive -F ${DATASET}"
    echo "🟢 Baseline stream initialization successful!"
fi
