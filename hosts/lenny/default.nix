{ config, lib, pkgs, ... }:
{
  services = {
    openssh.enable = true;
  };

  users.mutableUsers = false;
  users.users.root.passwordFile = "/nix/persist/shadow_sean";
  users.users.sean.passwordFile = "/nix/persist/shadow_sean";

  environment.etc =
    lib.genAttrs
      [
        "machine-id"
        "NetworkManager/system-connections"
        "ssh/ssh_host_ed25519_key"
        "ssh/ssh_host_rsa_key"
      ]
      (name: { source = "/nix/persist/etc/${name}"; });

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
    "/" = { device = "lenny/locker/tmproot"; fsType = "zfs"; };
    "/nix" = { device = "lenny/locker/nix"; fsType = "zfs"; };
    "/home" = { device = "lenny/locker/home"; fsType = "zfs"; };
    "/boot" = { device = "/dev/disk/by-partlabel/_esp"; fsType = "vfat"; };
    "/var/log" = { device = "/nix/persist/var/log"; noCheck = true; options = [ "bind" ]; };
  };

  system.stateVersion = "21.11";
}
