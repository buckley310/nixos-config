{ config, lib, ... }:
{
  imports = [ ../neo/configuration.nix ];
  services.getty.autologinUser = "root";
}
