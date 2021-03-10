{ config, pkgs, lib, ... }:
with lib;
let
  cfg = config.sconfig.profile;
in
{
  options.sconfig.profile = mkOption {
    type = types.enum [ "server" "desktop-gnome" "desktop-sway" ];
  };

  config = mkMerge [

    (mkIf (cfg == "server") (mkMerge [
      { services.openssh.enable = true; }
      (import ./auto-update.nix { })
    ]))

    (mkIf (cfg == "desktop-sway") (import ./sway.nix { inherit pkgs; }))
    (mkIf (cfg == "desktop-gnome") (import ./gnome.nix { inherit pkgs; }))

    (mkIf ("desktop-" == builtins.substring 0 8 cfg) (mkMerge [
      (import ./security-tools.nix { inherit pkgs; })
      (import ./graphical.nix { inherit pkgs; })
    ]))

  ];
}
