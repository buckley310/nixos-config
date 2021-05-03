{ config, ... }:
{
  sconfig.profile = "server";
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  fileSystems."/" = { device = "/dev/disk/by-partlabel/_root"; fsType = "ext4"; };
  fileSystems."/boot" = { device = "/dev/disk/by-partlabel/_esp"; fsType = "vfat"; };
  security.sudo.wheelNeedsPassword = false;
  users.users.root.openssh.authorizedKeys = config.users.users.sean.openssh.authorizedKeys;
}
