{ config, lib, pkgs, ... }:
{
  sconfig = {
    gnome = true;
    profile = "desktop";
    horizon.enable = true;
    wg-home.enable = true;
  };

  environment.etc.machine-id.source = "/var/lib/nixos/machine-id";

  environment.etc."NetworkManager/system-connections".source =
    "/var/lib/nixos/nm-connections";

  services.openssh = {
    enable = true;
    hostKeys = [
      { type = "ed25519"; path = "/var/lib/nixos/ssh_host_ed25519_key"; }
    ];
  };

  users.mutableUsers = false;
  users.users.sean.passwordFile = "/var/lib/nixos/shadow_sean";
  users.users.root.passwordFile = "/var/lib/nixos/shadow_sean";

  boot = {
    loader.systemd-boot.enable = true;
    loader.efi.canTouchEfiVariables = false;
  };

  hardware.cpu.intel.updateMicrocode = true;
  hardware.enableRedistributableFirmware = true;

  fileSystems = {
    "/" = { device = "tmpfs"; fsType = "tmpfs"; options = [ "mode=755" ]; };
    "/boot" = { device = "/dev/disk/by-partlabel/EFI\\x20system\\x20partition"; fsType = "vfat"; };
    "/home" = { device = "zroot/locker/home"; fsType = "zfs"; };
    "/nix" = { device = "zroot/locker/nix"; fsType = "zfs"; };
    "/var/lib" = { device = "zroot/locker/lib"; fsType = "zfs"; };
    "/var/log" = { device = "zroot/locker/log"; fsType = "zfs"; };
  };

  system.stateVersion = "21.05";
}
