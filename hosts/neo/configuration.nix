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

  environment.systemPackages = with pkgs; [
    vmware-horizon-client
    wine
    winetricks
  ];

  services = {
    openssh.enable = true;
    zfs.autoSnapshot = { enable = true; monthly = 0; weekly = 0; };
  };

  boot = {
    loader.systemd-boot.enable = true;
    loader.efi.canTouchEfiVariables = true;
    kernelParams = map (x: "video=DP-${x}:1280x720@60") [ "0" "1" "2" ];
  };

  fileSystems = {
    "/" = { device = "zroot/locker/os"; fsType = "zfs"; };
    "/home" = { device = "zroot/locker/home"; fsType = "zfs"; };
    "/boot" = { device = "/dev/disk/by-partlabel/_esp"; fsType = "vfat"; };
  };

  system.stateVersion = "20.09";
}
