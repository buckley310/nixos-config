#!/usr/bin/env bash

set -ex

cryptsetup -y -v luksFormat "/dev/disk/by-partlabel/_root1"
cryptsetup -y -v luksFormat "/dev/disk/by-partlabel/_root2"
cryptsetup --allow-discards open "/dev/disk/by-partlabel/_root1" cryptroot1
cryptsetup --allow-discards open "/dev/disk/by-partlabel/_root2" cryptroot2

mkfs.btrfs -f -L_root -mraid1 -draid1 /dev/mapper/cryptroot1 /dev/mapper/cryptroot2
mount /dev/disk/by-label/_root /mnt -o discard,compress=zstd:1

btrfs subvolume create /mnt/home
btrfs subvolume create /mnt/nix
mkdir /mnt/boot
