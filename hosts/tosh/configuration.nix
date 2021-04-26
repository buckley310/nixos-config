{ pkgs, ... }:
{
  services.tlp.enable = true;
  services.openssh.enable = true;

  networking.search = [ "bck.me" ];

  sconfig = {
    profile = "desktop";
    gnome = true;
    security-tools = true;
  };

  boot = {
    loader.grub.enable = true;
    loader.grub.device = "/dev/disk/by-id/wwn-0x50000391e71024d6";
    initrd.luks.devices.cryptroot = { device = "/dev/disk/by-id/wwn-0x50000391e71024d6-part2"; };
  };

  fileSystems = {
    "/" = { device = "/dev/mapper/cryptroot"; fsType = "btrfs"; options = [ "subvol=/os" "compress=zstd" ]; };
    "/home" = { device = "/dev/mapper/cryptroot"; fsType = "btrfs"; options = [ "subvol=/home" "compress=zstd" ]; };
    "/boot" = { device = "/dev/disk/by-id/wwn-0x50000391e71024d6-part1"; fsType = "ext4"; };
  };

  system.stateVersion = "21.05";
}
