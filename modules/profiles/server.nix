{ config, pkgs, lib, ... }:
with lib;
{
  config = mkIf (config.sconfig.profile == "server") {
    services.logind.lidSwitch = "ignore";
    documentation.nixos.enable = false;
    nix.gc = {
      automatic = true;
      options = "--delete-older-than 30d";
      randomizedDelaySec = "55min";
    };
  };
}
