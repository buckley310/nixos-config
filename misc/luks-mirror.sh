#!/usr/bin/env bash

set -e
read -p "Path to new LUKS device 1: " blkdevA
read -p "Path to new LUKS device 2: " blkdevB
set -x

cryptsetup -y -v luksFormat "$blkdevA"
cryptsetup -y -v luksFormat "$blkdevB"
cryptsetup --allow-discards open "$blkdevA" cryptroot1
cryptsetup --allow-discards open "$blkdevB" cryptroot2

mkfs.btrfs -f -L_root -mraid1 -draid1 /dev/mapper/cryptroot1 /dev/mapper/cryptroot2
mount /dev/disk/by-label/_root /mnt -o discard,compress=zstd:1

btrfs subvolume create /mnt/home
btrfs subvolume create /mnt/nix
mkdir /mnt/boot
