#!/bin/bash
# -----------------------------------------------------------------------------
# nemo-mesh-mount: Silent, On-Demand Network-Wide Mount Automator
# Primary Author: Gemini AI
# Co-Author: @kellystorm
# -----------------------------------------------------------------------------

MOUNT_BASE="/home/${USER}/network_mesh"
RCLONE_CONFIG="/home/${USER}/.config/rclone/rclone.conf"

if [ ! -f "$RCLONE_CONFIG" ]; then
    echo "❌ Error: Distributed rclone.conf missing from ~/.config/rclone/"
    exit 1
fi

# Extract all unique remote configurations out of the consolidated config file
REMOTES=$(grep -E '^\[.*\]$' "$RCLONE_CONFIG" | tr -d '[]')

echo "⚡ Initializing silent network fabric layer..."

for REMOTE in $REMOTES; do
    # Skip processing self if hostname matches configuration blocks
    if [ "$REMOTE" = "$(hostname)" ]; then continue; fi

    TARGET_PATH="${MOUNT_BASE}/${REMOTE}"
    mkdir -p "$TARGET_PATH"

    if ! mountpoint -q "$TARGET_PATH"; then
        echo "🏰 Mapping context window doors to neighbor node: $REMOTE"
        
        # Runs via FUSE daemon mode: silent and dormant unless actively opened
        rclone mount "${REMOTE}:/" "$TARGET_PATH" \
            --config "$RCLONE_CONFIG" \
            --vfs-cache-mode writes \
            --vfs-cache-max-age 10m \
            --no-modtime \
            --daemon
    fi
done
