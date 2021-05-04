{ pkgs, ... }:
{
  environment.systemPackages = [ pkgs.vmware-horizon-client ];

  services.tlp.enable = true;
  services.openssh.enable = true;

  networking.search = [ "bck.me" ];

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
    "/" = { device = "/dev/mapper/cryptroot"; fsType = "btrfs"; options = [ "subvol=/os" "compress=zstd" ]; };
    "/nix" = { device = "/dev/disk/by-id/wwn-0x5002538043584d30"; fsType = "btrfs"; options = [ "compress=zstd" "discard" ]; };
    "/boot" = { device = "/dev/disk/by-partlabel/_esp"; fsType = "vfat"; };
  };

  system.stateVersion = "21.05";
}
