{
  config,
  lib,
  pkgs,
  ...
}:

let
  aconfig = (pkgs.formats.toml { }).generate "alacritty.toml" {
    env.TERM = "xterm-256color";
    font.size = 12;
    window = {
      dynamic_padding = true;
      resize_increments = true;
      dimensions = {
        columns = 120;
        lines = 40;
      };
    };
    keyboard.bindings = [
      {
        action = "ScrollHalfPageDown";
        mode = "~Alt";
        mods = "Shift";
        key = "PageDown";
      }
      {
        action = "ScrollHalfPageUp";
        mode = "~Alt";
        mods = "Shift";
        key = "PageUp";
      }
      {
        action = "SpawnNewInstance";
        mods = "Control|Shift";
        key = "N";
      }
      {
        action = "SpawnNewInstance";
        mods = "Control|Shift";
        key = "T";
      }
    ];
    colors = {
      primary.background = "0x1e1e1e";
      primary.foreground = "0xffffff";
    };
    general.import = [ "${pkgs.alacritty-theme}/share/alacritty-theme/tango_dark.toml" ];
  };

in
{
  config = lib.mkIf (config.sconfig.desktop.enable) {
    environment.etc."xdg/alacritty.toml".source = aconfig;
    environment.systemPackages = [ pkgs.alacritty ];
  };
}
