{ pkgs, ... }:
{
  sconfig = {
    gnome = true;
    profile = "desktop";
    security-tools = true;
  };

  networking = {
    search = [ "bck.me" ];
  };

  environment.systemPackages = [ pkgs.vmware-horizon-client ];

  services = {
    pcscd.enable = true;
    openssh.enable = true;
    zfs.autoSnapshot = { enable = true; monthly = 0; weekly = 0; };
  };

  boot = {
    loader.systemd-boot.enable = true;
    loader.efi.canTouchEfiVariables = true;
    kernelPackages = pkgs.linuxPackages_5_10;
  };

  fileSystems = {
    "/" = { device = "zroot/locker/os"; fsType = "zfs"; };
    "/home" = { device = "zroot/locker/home"; fsType = "zfs"; };
    "/boot" = { device = "/dev/disk/by-partlabel/_esp"; fsType = "vfat"; };
  };

  system.stateVersion = "20.09";
}
