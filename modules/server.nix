{ config, pkgs, lib, ... }:
with lib;
{
  config = mkIf (config.sconfig.profile == "server") {
    services.openssh.enable = true;
    services.openssh.startWhenNeeded = true;
    documentation.nixos.enable = false;
    nix.gc = {
      automatic = true;
      options = "--delete-older-than 30d";
    };
  };
}
