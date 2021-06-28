#!/usr/bin/env bash

set -ex

cryptsetup -y -v luksFormat "/dev/disk/by-partlabel/_root"
cryptsetup --allow-discards open "/dev/disk/by-partlabel/_root" cryptroot

mkfs.btrfs -f -L_root /dev/mapper/cryptroot
mount /dev/disk/by-label/_root /mnt -o discard,compress=zstd:1

btrfs subvolume create /mnt/home
btrfs subvolume create /mnt/nix
mkdir /mnt/boot
