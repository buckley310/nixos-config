{ config, lib, ... }:
{
  services.qemuGuest.enable = true;
  sconfig.profile = "desktop";
  sconfig.gnome = true;
  services.getty.autologinUser = "root";
  fileSystems."/" = { device = "/dev/vda1"; fsType = "ext4"; };
  boot.loader.grub.device = "nodev";
}
