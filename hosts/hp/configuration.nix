{ pkgs, ... }:
{
  services = {
    openssh.enable = true;
  };

  sconfig = {
    gnome = true;
    profile = "desktop";
    security-tools = true;
  };

  networking = {
    search = [ "bck.me" ];
  };

  boot = {
    loader.systemd-boot.enable = true;
    loader.efi.canTouchEfiVariables = false;
    kernelPackages = pkgs.linuxPackages_5_11;
  };

  fileSystems = {
    "/" = { device = "zroot/locker/os"; fsType = "zfs"; };
    "/home" = { device = "zroot/locker/home"; fsType = "zfs"; };
    "/boot" = { device = "/dev/disk/by-partlabel/EFI\\x20system\\x20partition"; fsType = "vfat"; };
  };

  system.stateVersion = "20.09";
}
