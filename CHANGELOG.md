# Changelog

All notable changes to this project will be documented in this file. This project adheres strictly to Semantic Versioning (SemVer).

## - 2026-09-05
### Changed
- Rearranged workspace directories and source assets to accurately reflect the true point and purpose of our core Nemo extension: `nemo-zfs-thingsync`.
- Isolated secondary utilities into an entirely optional `helpers/` workspace structure, serving as high-value drop-in additions for complex environments.

## - 2026-09-05
### Added
- Integrated initial master configuration README.md documentation and detailed CHANGELOG.md mapping.
- Sealed the first viable major release step for the core metric mapping tools and baseline snapshot workers.

## - 2026-09-05
### Added
- Conceptual framework initialization for multi-node `zraid3` cluster monitoring and thin-client data-flow synchronization via Nemo.

## - 2026-09-05
### Changed
- Migrated filesystem-level file-versioning tasks from slow user-space copies (`.stversions`) to instant block-level OpenZFS dataset snapshots.

## - 2026-09-05
### Changed
- Shifted all structural namespaces and path arrays to rely uniformly on the semantic `nemo-` prefix framework.

## - 2026-09-05
### Added
- Initial operational build combining the Nemo extension hooks and Syncthing external snapshot automation scripts.
- tagged build as release 1.0.0.0

## - 2026-09-05
### Changed
- Broke apart monolithic codebase to correct a "gold-plating" design error.
- Split project into two distinct, isolated extensions: `nemo-zfs-metrics` (core visual performance fields) and `nemo-syncthing-copilot` (the optional automated versioning companion).

## - 2026-09-05
### Fixed
- Fixed OpenSSH hostname resolution loops by enforcing `-o IdentitiesOnly=yes` across all loopback bridges.
- Corrected filename depth nesting constraints to consistently use the semantic `nemo-` prefix (e.g., `~/.config/nemo-zfs/` and `nemo_zfs_plugin.py`).
- Optimized permission script routines to safely target directory schemas only (`find -type d -exec chmod 2775 "{}" +`), avoiding high-capacity dataset scanning bottlenecks.

## - 2026-09-05
### Added
- Standardized, configuration-agnostic deployment architecture.
- Abstracted `config.json` baseline using generic parameters (`rpool/USERDATA` and `/home/zfsuser/mnt`).
- Comprehensive `test_harness.py` test suite for configuration and parser integrity validation.
- Complete documentation and plug-and-play code layout.
- tagged build as release 1.1.0.0 