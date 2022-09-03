{ config, lib, pkgs, ... }:
{
  environment.etc =
    {
      "machine-id".source = "/var/lib/nixos/machine-id";

      "NetworkManager/system-connections".source =
        "/var/lib/nixos/network-connections";
    };

  systemd.tmpfiles.rules = [ "d /var/lib/nixos/network-connections 0700" ];

  services.openssh.hostKeys = [
    { type = "ed25519"; path = "/var/lib/nixos/ssh_host_ed25519_key"; }
  ];

  users.mutableUsers = false;
  users.users.root.passwordFile = "/nix/persist/shadow_sean";
  users.users.sean.passwordFile = "/nix/persist/shadow_sean";

  sconfig = {
    gnome = true;
    profile = "desktop";
    horizon.enable = true;
    wg-home.enable = true;
  };

  zramSwap.memoryPercent = 100;

  swapDevices = [{
    device = "/dev/disk/by-partuuid/e54894a7-f322-482c-b8f2-8e706f02f316";
    randomEncryption.enable = true;
  }];

  boot = {
    loader.systemd-boot.enable = true;
    loader.efi.canTouchEfiVariables = true;
    initrd.postDeviceCommands = lib.mkAfter ''
      zfs rollback lenny/locker/tmproot@blank
    '';
  };

  hardware.cpu.intel.updateMicrocode = true;
  hardware.enableRedistributableFirmware = true;

  fileSystems = {
    "/boot" = { device = "/dev/disk/by-partlabel/_esp"; fsType = "vfat"; };
    "/" = { device = "lenny/locker/tmproot"; fsType = "zfs"; };
    "/nix" = { device = "lenny/locker/nix"; fsType = "zfs"; };
    "/home" = { device = "lenny/locker/home"; fsType = "zfs"; };
    "/var/lib" = { device = "lenny/locker/lib"; fsType = "zfs"; };
    "/var/log" = { device = "lenny/locker/log"; fsType = "zfs"; };
  };

  system.stateVersion = "21.11";
}
