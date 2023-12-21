{ ... }:
let
  persist = "/nix/persist";
in
{
  sconfig = {
    gnome = true;
    desktop.enable = true;
    horizon.enable = true;
    wg-home.enable = true;
  };

  environment.etc.machine-id.source = "${persist}/machine-id";

  environment.persistence."${persist}/system".directories = [
    "/etc/NetworkManager/system-connections"
    "/var/lib/bluetooth"
    "/var/lib/nixos"
    "/var/lib/systemd/coredump"
    "/var/log/journal"
  ];

  services.openssh.hostKeys = [
    { type = "ed25519"; path = "${persist}/ssh_host_ed25519_key"; }
  ];

  users.mutableUsers = false;
  users.users.sean.hashedPasswordFile = "${persist}/shadow_sean";
  users.users.root.hashedPasswordFile = "${persist}/shadow_sean";

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
    "/var/log" = { device = "zroot/locker/log"; fsType = "zfs"; };
  };

  system.stateVersion = "22.05";
}
