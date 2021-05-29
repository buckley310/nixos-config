{ config, lib, ... }:
{
  services.qemuGuest.enable = true;
  sconfig.profile = "server";
  services.getty.autologinUser = "root";
}
