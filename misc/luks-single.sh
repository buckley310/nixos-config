#!/usr/bin/env bash

set -e
read -p "Path to new LUKS device: " blkdev
set -x

cryptsetup -y -v luksFormat "$blkdev"
cryptsetup --allow-discards open "$blkdev" cryptroot

mkfs.btrfs -f -L_root /dev/mapper/cryptroot
mount /dev/disk/by-label/_root /mnt -o discard,compress=zstd:1

btrfs subvolume create /mnt/home
btrfs subvolume create /mnt/nix
mkdir /mnt/boot
