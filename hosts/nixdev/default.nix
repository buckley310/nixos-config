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

  environment.variables.GTK_THEME = "Adwaita-dark";

  environment.etc =
    lib.genAttrs
      [
        "machine-id"
        "ssh/ssh_host_ed25519_key"
        "ssh/ssh_host_rsa_key"
      ]
      (name: { source = "/nix/persist/etc/${name}"; });

  boot.loader.grub = {
    enable = true;
    mirroredBoots = [{
      path = "/nix/persist/boot";
      devices = [ "/dev/sda" ];
    }];
  };

  fileSystems =
    {
      "/" = { device = "tmpfs"; fsType = "tmpfs"; options = [ "mode=755" ]; };
      "/nix" = { device = "/dev/sda1"; fsType = "ext4"; options = [ "noatime" ]; };
    };
}
