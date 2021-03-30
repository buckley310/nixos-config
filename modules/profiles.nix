{ config, pkgs, lib, ... }:
with lib;
let
  cfg = config.sconfig.profile;
in
{
  options.sconfig.profile = mkOption {
    type = types.enum [ "server" "desktop-gnome" "desktop-sway" "desktop-plasma" ];
  };

  config = mkMerge [

    (mkIf (cfg == "server") {
      services.openssh.enable = true;
      system.autoUpgrade = {
        enable = true;
        allowReboot = true;
      };
      nix.gc = {
        automatic = true;
        options = "--delete-older-than 30d";
      };
    })

    (mkIf (cfg == "desktop-sway") (import ./sway.nix { inherit pkgs; }))
    (mkIf (cfg == "desktop-gnome") (import ./gnome.nix { inherit pkgs; }))
    (mkIf (cfg == "desktop-plasma") (import ./plasma.nix { inherit pkgs; }))

    (mkIf ("desktop-" == builtins.substring 0 8 cfg) (mkMerge [
      (import ./graphical.nix { inherit pkgs; })
    ]))

  ];
}
