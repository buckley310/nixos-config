{ config, lib, pkgs, ... }:
{
  networking.hostName = "nixdev";

  sconfig = {
    gnome = true;
    profile = "desktop";
  };

  services.openssh.enable = true;

  users.mutableUsers = false;
  users.users.root.passwordFile = "/nix/persist/shadow_sean";
  users.users.sean.passwordFile = "/nix/persist/shadow_sean";

  environment.etc =
    builtins.listToAttrs (map
      (name: { inherit name; value.source = "/nix/persist/etc/${name}"; })
      [
        "machine-id"
        "ssh/ssh_host_ed25519_key"
        "ssh/ssh_host_rsa_key"
      ]);

  boot = {
    loader.systemd-boot.enable = true;
    loader.efi.canTouchEfiVariables = true;
  };

  fileSystems =
    {
      "/" = { device = "tmpfs"; fsType = "tmpfs"; options = [ "mode=755" ]; };
      "/boot" = { device = "/dev/disk/by-partlabel/_esp"; fsType = "vfat"; options = [ "discard" "noatime" ]; };
      "/nix" = { device = "/dev/disk/by-partlabel/_nix"; fsType = "ext4"; options = [ "discard" "noatime" ]; };
      "/home" = { device = "/nix/persist/home"; noCheck = true; options = [ "bind" ]; };
      "/var/log" = { device = "/nix/persist/var/log"; noCheck = true; options = [ "bind" ]; };
    };

  system.stateVersion = "21.05";
}
