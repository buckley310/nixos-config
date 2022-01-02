{ config, lib, pkgs, ... }:

# alacritty.yml is needed in both <current-system>/sw/etc/ and /etc/, or
# it won't work correctly in some environments (at least plasma+wayland)
# That's why it's in systemPackages AND environment.etc.
# (November 2021)

let
  cfg = config.sconfig.alacritty;

  configText = builtins.toJSON
    {
      env.TERM = "xterm-256color";
      key_bindings = [
        { action = "ScrollHalfPageDown"; mods = "Shift"; key = "PageDown"; }
        { action = "ScrollHalfPageUp"; mods = "Shift"; key = "PageUp"; }
        { action = "SpawnNewInstance"; mods = "Control|Shift"; key = "N"; }
        { action = "SpawnNewInstance"; mods = "Control|Shift"; key = "T"; }
      ];
    };

in
{
  options.sconfig.alacritty.enable = lib.mkEnableOption "Enable Alacritty";

  config = lib.mkIf cfg.enable {

    environment.etc."xdg/alacritty.yml".text = configText;

    environment.systemPackages = [
      pkgs.alacritty
      (pkgs.writeTextFile {
        name = "alacritty.yml";
        destination = "/etc/xdg/alacritty.yml";
        text = configText;
      })
    ];

    programs.bash.interactiveShellInit = ''
      function _set_title() {
        printf "\033]0;%s@%s:%s\007" "''${USER}" "''${HOSTNAME%%.*}" "''${PWD/#$HOME/\~}"
      }
      [ -z "$VTE_VERSION" ] && PROMPT_COMMAND="_set_title; $PROMPT_COMMAND"
    '';
  };
}
