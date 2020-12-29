{ config, pkgs, lib, ... }:
let
  cfg = config.sconfig.alacritty;

  alacritty_theme = pkgs.fetchurl {
    url = "https://raw.githubusercontent.com/eendroroy/alacritty-theme/0ea6ab87fed0d71dc9658dea95debc4124984607/themes/base16_default_dark.yaml";
    sha256 = "16zhhdg5wrjvlidch1cy4qhcpi47zfyv34zxlknfvh1k6d0mahcs";
  };

in
{
  options.sconfig.alacritty = lib.mkEnableOption "Patch libinput scroll speed";

  config = lib.mkIf cfg {
    environment.systemPackages = [ pkgs.alacritty ];

    programs.bash.interactiveShellInit = ''
      function _set_title() {
          printf "\033]0;%s@%s:%s\007" "''${USER}" "''${HOSTNAME%%.*}" "''${PWD/#$HOME/\~}"
      }
      [ -z "$VTE_VERSION" ] && PROMPT_COMMAND="_set_title; $PROMPT_COMMAND"
    '';

    environment.etc."xdg/alacritty.yml".text = ''
      env:
        TERM: xterm-256color
      key_bindings:
      - { key: N, mods: Control|Shift, action: SpawnNewInstance }
      - { key: T, mods: Control|Shift, action: SpawnNewInstance }
      ${builtins.readFile alacritty_theme}
    '';
  };
}
