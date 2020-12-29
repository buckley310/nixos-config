{ config, pkgs, lib, ... }:
with lib;
let
  cfg = config.sconfig;
in
{
  options.sconfig = {

    profile = mkOption {
      type = types.enum [ "server" "desktop-gnome" "desktop-sway" ];
    };

    scroll-boost = mkEnableOption "Patch libinput scroll speed";

  };

  config = mkMerge [

    (mkIf (cfg.profile == "server") (mkMerge [
      { services.openssh.enable = true; }
      (import ./modules/auto-update.nix { })
    ]))

    (mkIf (cfg.profile == "desktop-sway") (import ./modules/sway { inherit pkgs; }))
    (mkIf (cfg.profile == "desktop-gnome") (import ./modules/gnome { inherit pkgs; }))

    (mkIf ("desktop-" == builtins.substring 0 8 cfg.profile) (mkMerge [
      (import ./modules/security-tools.nix { inherit pkgs; })
      (import ./modules/graphical.nix { inherit pkgs; })
    ]))

    (mkIf cfg.scroll-boost (import ./modules/scroll-boost { }))

  ];

  imports = [
    ./modules/alacritty.nix
    ./modules/baseline.nix
    ./modules/cli.nix
    ./modules/status-on-console.nix
  ];
}
