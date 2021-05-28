{ config, lib, ... }:
{
  sconfig.profile = "desktop";
  sconfig.gnome = true;
  services.getty.autologinUser = "root";
}
