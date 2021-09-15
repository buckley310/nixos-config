{ pkgs, ... }:
{
  sconfig = {
    profile = "desktop";
    gnome = true;
    security-tools = true;
  };

  boot = {
    loader.systemd-boot.enable = true;
    loader.efi.canTouchEfiVariables = true;
    initrd.luks.devices.cryptroot = { device = "/dev/disk/by-partlabel/_luks"; };
  };

  fileSystems = {
    "/" = { device = "/dev/mapper/cryptroot"; fsType = "btrfs"; options = [ "subvol=/os" "discard" "compress=zstd" ]; };
    "/home" = { device = "/dev/mapper/cryptroot"; fsType = "btrfs"; options = [ "subvol=/home" "discard" "compress=zstd" ]; };
    "/boot" = { device = "/dev/disk/by-partlabel/_esp"; fsType = "vfat"; };
  };

  system.stateVersion = "21.05";
}
