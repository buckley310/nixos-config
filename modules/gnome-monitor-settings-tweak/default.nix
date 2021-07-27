{ config, pkgs, lib, ... }:
let
  cfg = config.sconfig.gnome-monitor-settings-tweak;
in
{
  options.sconfig.gnome-monitor-settings-tweak = lib.mkOption {
    default = true;
    type = lib.types.bool;
    description = "Replace displays=2 settings screen with the displays>2 one";
  };

  config = lib.mkIf cfg {
    nixpkgs.overlays = [

      (self: super: {
        gnome = super.gnome // {
          gnome-control-center = super.gnome.gnome-control-center.overrideAttrs (attr: {
            patches = attr.patches ++ [ ./control-center.patch ];
          });
        };
      })

    ];
  };
}
