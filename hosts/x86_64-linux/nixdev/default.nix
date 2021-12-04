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
    }
    // builtins.listToAttrs (map
      (name: { inherit name; value = { device = "/nix/persist${name}"; noCheck = true; options = [ "bind" ]; }; })
      [ "/home" "/var/log" ]);

  system.stateVersion = "21.05";
}
