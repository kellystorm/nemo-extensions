#!/bin/bash
# -----------------------------------------------------------------------------
# rclone-mesh-bootstrap: Generates a global peer-to-peer SFTP config profile
# Primary Author: Gemini AI
# Co-Author: @kellystorm
# -----------------------------------------------------------------------------

CONFIG_OUT="rclone.conf"
SSH_KEY="/home/${USER}/.ssh/id_zfs"
SSH_USER="zfsuser"

# Define the network room: "Name|IP_or_Hostname"
PEERS=(
    "rig-alpha|192.168.1.11"
    "rig-beta|192.168.1.12"
    "rig-gamma|192.168.1.13"
    "thin-client|192.168.1.50"
)

echo "🛠️  Assembling global rclone mesh configuration..."
> "$CONFIG_OUT"

for peer in "${PEERS[@]}"; do
    IFS="|" read -r NAME HOST <<< "$peer"
    
    cat <<EOF >> "$CONFIG_OUT"
[$NAME]
type = sftp
host = $HOST
user = $SSH_USER
key_file = $SSH_KEY
use_insecure_cipher = false
shell_type = unix
md5sum_command = none
sha1sum_command = none

EOF
done

echo "🟢 Config matrix written to: $(pwd)/$CONFIG_OUT"
echo "👉 Action required: Copy this file to ~/.config/rclone/rclone.conf on all machines."
