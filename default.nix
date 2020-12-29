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

    status-on-console = mkEnableOption "Display Neofetch on system console";

  };

  config = mkMerge [

    (import ./modules/cli.nix { inherit config pkgs lib; })
    (import ./modules/baseline.nix { inherit config pkgs lib; })

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
    (mkIf cfg.status-on-console (import ./modules/status-on-console { inherit pkgs; }))

  ];

  imports = [
    ./modules/alacritty.nix
  ];
}
