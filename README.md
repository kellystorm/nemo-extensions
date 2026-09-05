# nemo-extensions

A lightweight, non-blocking open-source toolkit optimizing user-space file manager interactions for high-performance OpenZFS file clusters. Designed to unbundle raw dataset visibility from automation sync tasks without producing file duplication overhead.

**nemo-zfs-metrics** extends Nemo to allow a client to gracefully mount neighbors within a network, where everything has been optimized for this crazy new world of Wayland, hyper-security, and SSHFS fatigue - thin-clients within the network can now traverse its neighbors securely and swiftly

**nemo-syncthing-copilot** builds upon nemo-zfs-metrics, tidying up everything once you've reach SyncThing's perfect configuration settings point and know that it's time for ZFS to join in the fun and finish the job. By 'job' I mean to say that SyncThing file versioning on a machine playing by the new world's new rules (Wayland, ZFS for root on NVMe, ZFS for data clusters, etc.) isn't necessary if you allow this copilot to, well, sit copilot and handle the ZFS snapshots outright so you don't have to task SyncThing with conducting work above its own pay grade (my opinion, not fact, I love you SyncThing)

---

## 🛠️ Step-by-Step Installation

### Step 1: Clone and Configure Environment Profiles
1. Create the unified configuration directory:
   ```bash
   mkdir -p ~/.config/nemo-zfs/
   #if you'd rather copy and update instead of build, as per the following step
   cp nemo-zfs-metrics/example.config.json ~/.config/nemo-zfs/config.json
   ```
2. Build your local properties manifest (`~/.config/nemo-zfs/config.json`) using matching system endpoints:
   ```json
   {
     "dataset_name": "rpool/USERDATA",
     "mount_path": "/home/zfsuser/mnt",
     "ssh_key_path": "/home/zfsuser/.ssh/id_zfs",
     "ssh_user": "zfsuser",
     "snapshot_prefix": "st_auto_",
     "snapshot_retention": 30
   }
   ```

### Step 2: Establish the Security Bridge & Shared Permissions
Ensure system identities and file privileges match across running daemons (Plex, Web Contexts, Syncthing) without introducing recursive I/O metadata blockages.

1. **Enroll Users and System Services:**
   Create or match your unified data storage access group, enrolling background worker profiles alongside your primary desktop identity:
   ```bash
   sudo groupadd shared_storage
   sudo usermod -aG shared_storage \$USER
   sudo usermod -aG shared_storage plex
   ```

2. **Enforce Directory-Only Group Sticky Bits (High Efficiency):**
   *CRITICAL:* Do not run a recursive `chmod -R` over massive production arrays; doing so can cause heavy storage metadata churn. Target the directory skeleton directly, using explicit quotes to safely handle underlying spaces or atypical names:
   ```bash
   sudo chgrp -R shared_storage /home/zfsuser/mnt
   sudo find /home/zfsuser/mnt -type d -exec chmod 2775 "{}" +
   sudo find /home/zfsuser/mnt -type d -exec chmod g+s "{}" +
   ```

3. **Generate the Loopback Identity Keys:**
   ```bash
   ssh-keygen -t ed25519 -f ~/.ssh/id_zfs -N ""
   ```
4. Append the public key string (`~/.ssh/id_zfs.pub`) straight into your target node's `authorized_keys`.

---

## 📂 Independent Modules

### 1. nemo-zfs-metrics
Injects non-blocking ZSTD compression ratios and true referenced allocations straight into Nemo column blocks.
* Copy `nemo_zfs_plugin.py` to `~/.local/share/nemo/extensions-python/`
* Grant execution privileges explicitly: `chmod +x ~/.local/share/nemo/extensions-python/nemo_zfs_plugin.py`
* Restart file manager daemon: `nemo -q`

### 2. nemo-syncthing-copilot
Binds to Syncthing's External File Versioning profile to substitute raw copy operations with microsecond ZFS block snapshots.
* Deploy `syncthing-zfs-snapshot.sh` to `/usr/local/bin/`
* Grant execution privileges explicitly: `sudo chmod +x /usr/local/bin/syncthing-zfs-snapshot.sh`
* Point Syncthing Web UI Folder -> File Versioning -> External File Versioning command block to the script path.
