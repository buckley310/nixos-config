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

  environment.systemPackages = with pkgs; [
    vmware-horizon-client
  ];

  boot = {
    loader.systemd-boot.enable = true;
    loader.efi.canTouchEfiVariables = false;
  };

  fileSystems = {
    "/" = { device = "zroot/locker/os"; fsType = "zfs"; };
    "/home" = { device = "zroot/locker/home"; fsType = "zfs"; };
    "/boot" = { device = "/dev/disk/by-partlabel/EFI\\x20system\\x20partition"; fsType = "vfat"; };
  };

  system.stateVersion = "20.09";
}
