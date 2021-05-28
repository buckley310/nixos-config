{ config, lib, ... }:
{
  sconfig.profile = "server";
  services.getty.autologinUser = "root";
}
