{ pkgs, ... }:
{
  environment.systemPackages = [ pkgs.vmware-horizon-client ];

  services.tlp.enable = true;
  services.openssh.enable = true;

  networking.hostName = "manta";
  networking.search = [ "bck.me" ];

  sconfig = {
    profile = "desktop";
    gnome = true;
    security-tools = true;
  };

  boot = {
    loader.systemd-boot.enable = true;
    loader.efi.canTouchEfiVariables = true;
    initrd.luks.devices.cryptroot = { device = "/dev/disk/by-partlabel/_root"; allowDiscards = true; };
  };

  fileSystems = {
    "/" = { device = "/dev/mapper/cryptroot"; fsType = "btrfs"; options = [ "subvol=/os" "compress=zstd" "discard" ]; };
    "/home" = { device = "/dev/mapper/cryptroot"; fsType = "btrfs"; options = [ "subvol=/home" "compress=zstd" "discard" ]; };
    "/boot" = { device = "/dev/disk/by-partlabel/_esp"; fsType = "vfat"; };
  };

  system.stateVersion = "20.09";
}
