{ config, lib, pkgs, ... }:
{
  sconfig = {
    gnome = true;
    hardware = "qemu";
    profile = "desktop";
  };

  services.openssh.enable = true;

  users.mutableUsers = false;
  users.users.root.passwordFile = "/nix/persist/shadow_sean";
  users.users.sean.passwordFile = "/nix/persist/shadow_sean";

  environment.persistence."/nix/persist" = {
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

  boot = {
    loader.systemd-boot.enable = true;
    loader.efi.canTouchEfiVariables = true;
  };

  fileSystems =
    {
      "/" = { device = "tmpfs"; fsType = "tmpfs"; options = [ "mode=755" ]; };
      "/boot" = { device = "/dev/disk/by-partlabel/_esp"; fsType = "vfat"; options = [ "discard" "noatime" ]; };
      "/nix" = { device = "/dev/disk/by-partlabel/_nix"; fsType = "ext4"; options = [ "discard" "noatime" ]; };
    };

  system.stateVersion = "21.05";
}
