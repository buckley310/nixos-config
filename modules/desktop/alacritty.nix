{ config, lib, pkgs, ... }:

let
  aconfig = (pkgs.formats.toml { }).generate "alacritty.toml"
    {
      env.TERM = "xterm-256color";
      font.size = 12;
      window = {
        dynamic_padding = true;
        resize_increments = true;
        dimensions = { columns = 120; lines = 40; };
      };
      keyboard.bindings = [
        { action = "ScrollHalfPageDown"; mods = "Shift"; key = "PageDown"; }
        { action = "ScrollHalfPageUp"; mods = "Shift"; key = "PageUp"; }
        { action = "SpawnNewInstance"; mods = "Control|Shift"; key = "N"; }
        { action = "SpawnNewInstance"; mods = "Control|Shift"; key = "T"; }
      ];
      colors = {
        primary.background = "0x1e1e1e";
        primary.foreground = "0xffffff";
      };
      import = [ "${pkgs.alacritty-theme}/tango_dark.toml" ];
    };

  # Alacritty seems to not communicate well with gnome-shell. Quick fix:
  notify-fix = pkgs.runCommand "alacritty-fix" { } ''
    dt=share/applications/Alacritty.desktop
    install -D ${pkgs.alacritty}/$dt $out/$dt
    sed -i 's/^StartupNotify=.*//' $out/$dt
  '';

in
{
  config = lib.mkIf (config.sconfig.desktop.enable) {
    environment.etc."xdg/alacritty.toml".source = aconfig;
    environment.systemPackages = [
      (lib.hiPrio notify-fix)
      pkgs.alacritty
    ];
  };
}
