#!/usr/bin/env python3
"""
ZFS-for-Nemo: A lightweight, multi-node ZFS dataset metrics viewer for the Nemo File Manager.
Primary Author: Gemini AI
Co-Author: k
"""

import os
import json
import subprocess
import threading
from gi.repository import Nemo, GObject

# --- ENFORCED SEMANTIC CONFIG PATH ---
CONFIG_PATH = os.path.expanduser("~/.config/nemo-zfs/config.json")

# Standardized generic template configuration fallbacks
CONFIG = {
    "dataset_name": "rpool/USERDATA",
    "mount_path": "/home/zfsuser/mnt",
    "ssh_key_path": os.path.expanduser("~/.ssh/id_zfs"),
    "ssh_user": "zfsuser"
}

if os.path.exists(CONFIG_PATH):
    try:
        with open(CONFIG_PATH, "r") as f:
            CONFIG.update(json.load(f))
    except Exception:
        pass

ZFS_CACHE = {}
cache_lock = threading.Lock()

class ZfsMetricsColumn(GObject.GObject, Nemo.ColumnProvider, Nemo.InfoProvider):
    def __init__(self):
        super().__init__()

    def get_columns(self):
        return [
            Nemo.Column(name="NemoPython::zfs_compress", attribute="zfs_compress", label="ZFS Compress"),
            Nemo.Column(name="NemoPython::zfs_written", attribute="zfs_written", label="ZFS Referenced")
        ]

    def _fetch_zfs_metrics(self, file_info, local_path):
        try:
            cmd = [
                "ssh", "-i", CONFIG["ssh_key_path"],
                "-o", "IdentitiesOnly=yes",
                "-o", "ConnectTimeout=1", 
                "-o", "StrictHostKeyChecking=no",
                f"{CONFIG['ssh_user']}@localhost",
                f"zfs get -H -o value compressratio,referenced {CONFIG['dataset_name']}"
            ]
            
            output = subprocess.check_output(cmd, stderr=subprocess.DEVNULL).decode("utf-8").splitlines()
            
            if len(output) >= 2:
                ratio = output[0].strip()
                referenced = output[1].strip()
                
                with cache_lock:
                    ZFS_CACHE[local_path] = {"ratio": f"⚡ {ratio}x", "written": referenced}
                GObject.idle_add(self._update_ui, file_info, local_path)
        except Exception:
            with cache_lock:
                ZFS_CACHE[local_path] = {"ratio": "⚠️ Link Error", "written": "—"}
            GObject.idle_add(self._update_ui, file_info, local_path)

    def _update_ui(self, file_info, local_path):
        with cache_lock:
            data = ZFS_CACHE.get(local_path)
        if data:
            file_info.add_string_attribute("zfs_compress", data["ratio"])
            file_info.add_string_attribute("zfs_written", data["written"])
            file_info.invalidate_extension_info()

    def update_file_info(self, file_info):
        uri = file_info.get_uri()
        target_prefix = f"file://{CONFIG['mount_path']}"
        if not uri.startswith(target_prefix):
            return
        local_path = uri.replace("file://", "")

        with cache_lock:
            if local_path in ZFS_CACHE:
                file_info.add_string_attribute("zfs_compress", ZFS_CACHE[local_path]["ratio"])
                file_info.add_string_attribute("zfs_written", ZFS_CACHE[local_path]["written"])
                return

        threading.Thread(target=self._fetch_zfs_metrics, args=(file_info, local_path), daemon=True).start()
