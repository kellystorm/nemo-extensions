# nemo-extensions

A lightweight, non-blocking open-source toolkit optimizing user-space file manager interactions for high-performance OpenZFS file clusters. Designed to unbundle raw dataset visibility from automation sync tasks without producing file duplication overhead.

## nemo-zfs-thingsync

A hardened, lightweight Nemo extension workflow built for power users running high-performance OpenZFS file pools (`zraid3`, `NVMe`, `1M recordsize`) across multiple machines on a local network.

### 🚀 The Core Philosophy: nemo-zfs-thingsync

`nemo-zfs-thingsync` does everything traditional user-space file-sync solutions (like Syncthing or rclone) *cannot* do. Instead of tracking file descriptors, fighting `.dotfile`/`.dotfolder` caches, or tripping over open database locks (`/var/lib/`, SQLite, active IDE workspaces), this extension exploits the OpenZFS block layer natively.

When you right-click a directory and trigger a transposition, the engine instantly freezes filesystem states via microsecond snapshots and flings the block deltas (`zfs send -i`) down the wire. It translates intent instantly: **"See workspace there? Shazam. Workspace now here."**

---

### 🛠️ Installation Step-by-Step

#### Step 1: Initialize Global Properties
1. Initialize the target configuration workspace directory:
   ```bash
   mkdir -p ~/.config/nemo-zfs/
   ```
2. Build your manifest environment profile (`~/.config/nemo-zfs/config.json`) or copy the workspace example configuration file:
   ```bash
   cp nemo-zfs-thingsync/example.config.json ~/.config/nemo-zfs/config.json
   ```
3. Populate it with your matching endpoints:
   ```json
   {
     "dataset_name": "rpool/USERDATA",
     "mount_path": "/home/zfsuser/mnt",
     "ssh_key_path": "/home/zfsuser/.ssh/id_zfs",
     "ssh_user": "zfsuser",
     "snapshot_prefix": "st_auto_",
     "snapshot_retention": 30,
     "desktop_host": "desktop-rig.local",
     "thin_client_host": "thin-client.local"
   }
   ```

#### Step 2: Establish the Security Bridge & Shared Permissions
Ensure cross-service boundaries match smoothly without introducing recursive metadata bottlenecks across high-capacity pools.

1. **Enroll Users and System Services:**
   Create or match your unified data storage access group, enrolling background worker profiles alongside your primary desktop identity:
   ```bash
   sudo groupadd shared_storage
   sudo usermod -aG shared_storage \$USER
   sudo usermod -aG shared_storage plex
   ```

2. **Enforce Directory-Only Sticky Bits (High-Speed Metadata Traversal):**
   *CRITICAL:* Do not run recursive optimizations over production arrays. Target directory skeletons exclusively, using explicit quotes to safely bypass atypical string names or spaces:
   ```bash
   sudo chgrp -R shared_storage /home/zfsuser/mnt
   sudo find /home/zfsuser/mnt -type d -exec chmod 2775 "{}" +
   sudo find /home/zfsuser/mnt -type d -exec chmod g+s "{}" +
   ```

3. **Generate Identity Keys:**
   ```bash
   ssh-keygen -t ed25519 -a 100 -f ~/.ssh/id_zfs -N ""
   ```
4. Append the public string (`~/.ssh/id_zfs.pub`) to the target node `authorized_keys`.

---

### 📂 Core Deployment

#### 1. Activating the UI Performance Columns
* Copy `nemo_zfs_plugin.py` straight into your local user extensions folder:
  ```bash
  cp nemo-zfs-thingsync/nemo_zfs_plugin.py ~/.local/share/nemo/extensions-python/
  ```
* Grant execution rights explicitly:
  ```bash
  chmod +x ~/.local/share/nemo/extensions-python/nemo_zfs_plugin.py
  ```
* Restart the desktop panel loop manager completely:
  ```bash
  nemo -q
  ```
* Select **ZFS Compress** and **ZFS Referenced** in column options.

#### 2. Activating the Transposition Engine
* Copy the context configuration file to your actions folder:
  ```bash
  cp nemo-zfs-thingsync/nemo_zfs_migration.nemo_action ~/.local/share/nemo/actions/
  ```
* Copy the backend transposition logic script to your binary path:
  ```bash
  sudo cp nemo-zfs-thingsync/nemo-zfs-migrate.sh /usr/local/bin/
  ```
* Grant system execution privileges explicitly:
  ```bash
  sudo chmod +x /usr/local/bin/nemo-zfs-migrate.sh
  ```

---

## 🎁 Optional Helper Scripts (`/helpers/`)

If you are deploying `nemo-zfs-thingsync`, the chances are incredibly high that you run complex daemon services alongside it. We have packaged standalone companion tools to assist your workflow perimeter:

* **`test_harness.py`:** Pre-flight configuration validation module built specifically for the core `nemo-zfs-thingsync` environment. Run to confirm that path splits, storage bindings, and configuration variables validate cleanly before linking active scripts:
  ```bash
  python3 helpers/test_harness.py
  ```

* **`syncthing-zfs-snapshot.sh`:** An external snapshot automation tool. Connect it to Syncthing's *External File Versioning* loop to substitute slow, user-space file duplication (`.stversions`) with native, zero-copy block preservation:
  * Deploy to your binary path and grant execution permissions explicitly:
    ```bash
    sudo cp helpers/syncthing-zfs-snapshot.sh /usr/local/bin/
    sudo chmod +x /usr/local/bin/syncthing-zfs-snapshot.sh
    ```

* **`rclone-mesh-bootstrap.sh` & `nemo-mesh-mount.sh`:** If you operate across a larger group of network environments, you can make every node visible to Nemo's layout via silent, on-demand background mountpoints:
  1. Open `helpers/rclone-mesh-bootstrap.sh` and populate your network machine definitions inside the `PEERS` array.
  2. Run the generator to write your central config mapping profile:
     ```bash
     chmod +x helpers/rclone-mesh-bootstrap.sh
     ./helpers/rclone-mesh-bootstrap.sh
     ```
  3. Copy the output file into place on every client machine:
     ```bash
     cp helpers/rclone.conf ~/.config/rclone/rclone.conf
     ```
  4. Deploy and execute the runtime mounting hook, or add it to your desktop login startup commands list:
     ```bash
     chmod +x helpers/nemo-mesh-mount.sh
     ./helpers/nemo-mesh-mount.sh
     ```
     *Note: Drives sit completely dark and silent inside the kernel layer, spinning up resources dynamically only when an application pane actively clicks inside them.*

* **`nemo-zfs-prune.sh`:** A rolling transposition snapshot pruner. It handles data-pool maintenance by cutting old transposition snapshots (`@migrate_`) off at the pass, preserving fallback anchors while destroying stale metadata accumulations.
  * Deploy to your binary path and grant execution permissions explicitly:
    ```bash
    sudo cp helpers/nemo-zfs-prune.sh /usr/local/bin/
    sudo chmod +x /usr/local/bin/nemo-zfs-prune.sh
    ```
#### Automating the Pruner (Recommended)
To prevent your migration snapshots from accumulating indefinitely over weeks of continuous deployment, orchestrate `nemo-zfs-prune.sh` to run automatically via your local user `crontab`:

1. Open your user cron configuration panel:
   ```bash
   crontab -e
   ```
2. Append the following block to trigger the pruning worker silently every night at midnight:
   ```text
   0 0 * * * /usr/local/bin/nemo-zfs-prune.sh >/dev/null 2>&1
   ```
