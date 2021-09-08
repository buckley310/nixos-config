{ config, pkgs, lib, ... }:
let
  cfg = config.sconfig.alacritty;
in
{
  options.sconfig.alacritty.enable = lib.mkEnableOption "Enable Alacritty";

  config = lib.mkIf cfg.enable {

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
      - { key: PageUp,   mods: Shift, action: ScrollHalfPageUp }
      - { key: PageDown, mods: Shift, action: ScrollHalfPageDown }
    '';

  };
}
