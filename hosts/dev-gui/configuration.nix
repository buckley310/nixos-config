{ config, lib, ... }:
{
  services.qemuGuest.enable = true;
  sconfig.profile = "desktop";
  sconfig.gnome = true;
  services.getty.autologinUser = "root";
}
