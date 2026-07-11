#!/usr/bin/env bash
# profiles/aetheros/profiledef.sh

iso_name="aetheros"
iso_label="AETHEROS_01"
iso_publisher="aetherOS Project <https://github.com/anphuni/aetherOS>"
iso_application="aetherOS Live/Rescue CD"
iso_version="0.1.0-demo.1"
install_dir="aetheros"
buildmodes=("iso")
bootmodes=("uefi.grub")
arch="x86_64"

# File permissions (uid, gid, mode)
file_permissions=(
    ["/etc/sudoers.d/demo"]="0:0:0440"
)

# Required by archiso ≥83/88 (limit-test LT-2 fix 2026-07-10)
pacman_conf="pacman.conf"
airootfs_image_type="squashfs"
airootfs_image_tool_options=('-comp' 'xz' '-Xbcj' 'x86' '-b' '1M' '-Xdict-size' '1M')
