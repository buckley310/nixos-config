{ config, pkgs, lib, ... }:
with lib;
let
  cfg = config.sconfig.profile;
in
{
  options.sconfig.profile = mkOption {
    type = types.enum [ "server" "desktop" ];
  };

  config = mkMerge [

    (mkIf (cfg == "server") {
      services.openssh.enable = true;
      documentation.nixos.enable = false;
      nix.gc = {
        automatic = true;
        options = "--delete-older-than 30d";
      };
    })

    (mkIf (cfg == "desktop") (import ./graphical.nix { inherit pkgs config; }))

  ];
}
