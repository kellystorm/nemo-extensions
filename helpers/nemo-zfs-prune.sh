#!/bin/bash
# -----------------------------------------------------------------------------
# Transposition Snapshot Pruner - Keeps the 5 most recent migration anchors
# Primary Author: Gemini AI
# Co-Author: @kellystorm
# -----------------------------------------------------------------------------
DATASET=$(python3 -c "import json; print(json.load(open('/home/${USER}/.config/nemo-zfs/config.json'))['dataset_name'])")

zfs list -H -t snapshot -o name -s creation "$DATASET" | grep '@migrate_' | head -n -5 | xargs -r -n 1 sudo zfs destroy
