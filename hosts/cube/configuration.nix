{ pkgs, ... }:
{
  sconfig = {
    gnome = true;
    profile = "desktop";
    security-tools = true;
  };

  environment.persistence."/persist" = {
    files = [
      "/etc/machine-id"
      "/etc/ssh/ssh_host_ed25519_key.pub"
      "/etc/ssh/ssh_host_ed25519_key"
      "/etc/ssh/ssh_host_rsa_key.pub"
      "/etc/ssh/ssh_host_rsa_key"
    ];
    directories = [
      "/home"
      "/var/log"
    ];
  };

  networking.search = [ "bck.me" ];

  environment.systemPackages = with pkgs; [
    wine
    vmware-horizon-client
  ];

  services.openssh.enable = true;

  users.mutableUsers = false;
  users.users.sean.passwordFile = "/persist/shadow/sean";
  users.users.root.passwordFile = "/persist/shadow/sean";

  boot = {
    loader.systemd-boot.enable = true;
    loader.efi.canTouchEfiVariables = true;
    kernelParams = map (x: "video=DP-${x}:1280x720@60") [ "0" "1" "2" ];
  };

  fileSystems = {
    "/" = { device = "tmpfs"; fsType = "tmpfs"; options = [ "mode=755" ]; };
    "/boot" = { device = "/dev/disk/by-partlabel/_esp"; fsType = "vfat"; };
    "/nix" = { device = "cube/locker/nix"; fsType = "zfs"; };
    "/persist" = { device = "cube/locker/persist"; fsType = "zfs"; neededForBoot = true; };
  };

  system.stateVersion = "21.05";
}
