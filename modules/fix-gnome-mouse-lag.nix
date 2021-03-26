{ config, pkgs, lib, ... }:
let
  cfg = config.sconfig.fix-gnome-mouse-lag;
in
{
  options.sconfig.fix-gnome-mouse-lag = lib.mkEnableOption "Reduce mouse latency on wayland";

  config = lib.mkIf cfg {
    nixpkgs.overlays = [
      (self: super: {
        gnome3 = super.gnome3 // {
          gnome-shell = super.gnome3.gnome-shell.override {
            mutter = super.gnome3.mutter.overrideAttrs (old: {
              patches = old.patches ++ [
                (pkgs.fetchurl {
                  url = "https://gitlab.gnome.org/GNOME/mutter/-/merge_requests/168.patch";
                  sha256 = "f9e71b14c791ac7553ff4ed2d0d5b612fc886c5aa771587965a6ffd99cb98b86";
                })
              ];
            });
          };
        };
      })
    ];
  };

}
