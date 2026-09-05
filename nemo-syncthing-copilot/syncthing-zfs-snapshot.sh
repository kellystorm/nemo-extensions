#!/bin/bash
# -----------------------------------------------------------------------------
# Standalone Dataset Snapshot Hook & Pruner
# Primary Author: Gemini AI
# Co-Author: k
# -----------------------------------------------------------------------------

# Unified namespace directory hook
CONFIG_FILE="/home/${USER}/.config/nemo-zfs/config.json"

get_config_val() {
    python3 -c "import json; print(json.load(open('$CONFIG_FILE'))['$1'])" 2>/dev/null
}

DATASET=$(get_config_val "dataset_name")
SSH_KEY=$(get_config_val "ssh_key_path")
SSH_USER=$(get_config_val "ssh_user")
PREFIX=$(get_config_val "snapshot_prefix")
RETENTION_COUNT=$(get_config_val "snapshot_retention")

# Reliable architectural generic fallbacks
DATASET=${DATASET:-"rpool/USERDATA"}
SSH_KEY=${SSH_KEY:-"/home/zfsuser/.ssh/id_zfs"}
SSH_USER=${SSH_USER:-"zfsuser"}
PREFIX=${PREFIX:-"st_auto_"}
RETENTION_COUNT=${RETENTION_COUNT:-30}

SNAP_NAME="${DATASET}@${PREFIX}$(date +%Y%m%d_%H%M%S)"

# Pinned loops execution leveraging explicit configuration variables
ssh -i "$SSH_KEY" -o IdentitiesOnly=yes -o StrictHostKeyChecking=no "${SSH_USER}@localhost" "sudo zfs snapshot ${SNAP_NAME}"

SNAPSHOTS=$(ssh -i "$SSH_KEY" -o IdentitiesOnly=yes -o StrictHostKeyChecking=no "${SSH_USER}@localhost" \
    "zfs list -H -t snapshot -o name -s creation ${DATASET} | grep '@${PREFIX}'")

CURRENT_COUNT=$(echo "$SNAPSHOTS" | wc -l)

if [ "$CURRENT_COUNT" -gt "$RETENTION_COUNT" ]; then
    PRUNE_LIMIT=$((CURRENT_COUNT - RETENTION_COUNT))
    echo "$SNAPSHOTS" | head -n "$PRUNE_LIMIT" | while read -r OLD_SNAP; do
        ssh -i "$SSH_KEY" -o IdentitiesOnly=yes -o StrictHostKeyChecking=no "${SSH_USER}@localhost" "sudo zfs destroy ${OLD_SNAP}"
    done
fi
