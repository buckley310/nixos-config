{ config, ... }:
{
  sconfig.profile = "server";
  boot.loader.grub.device = "/dev/vda";
  fileSystems."/" = { device = "/dev/vda1"; fsType = "ext4"; };
  security.sudo.wheelNeedsPassword = false;
  users.users.root.openssh.authorizedKeys = config.users.users.sean.openssh.authorizedKeys;
}
