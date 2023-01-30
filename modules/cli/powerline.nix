{ config, pkgs, lib, ... }:
let

  cfg = config.sconfig.powerline;

  theme = pkgs.writeText "powerline.json" (builtins.toJSON
    {
      BoldForeground = true;
      CwdFg = 15;
      PathBg = 24;
      PathFg = 15;
      SeparatorFg = 16;
    });

in
{
  options.sconfig.powerline =
    {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = true;
      };
      args = lib.mkOption {
        type = lib.types.listOf lib.types.str;
        default = [
          "-modules=\${remote:+'user,host,'}nix-shell,git,jobs,cwd"
          "-git-assume-unchanged-size 0"
          "-theme ${theme}"
          "-path-aliases '~/git=~/git'"
          "-jobs $(jobs -p | wc -l)"
        ];
      };
    };

  config = lib.mkIf cfg.enable {

    environment.systemPackages = [ pkgs.powerline-go ];

    programs.bash.interactiveShellInit = ''
      function _fix_partial_lines() {
        # print our own newline if program output doesn't end with one
        local COL
        local ROW
        IFS=';' read -sdR -p $'\e[6n' ROW COL
        [ "$COL" = "1" ] || echo -e '\e[100m \e[0m'
      }
      function _update_ps1() {
        local remote=y
        [ "$XDG_SESSION_TYPE" = "x11" ] && unset remote
        [ "$XDG_SESSION_TYPE" = "wayland" ] && unset remote
        PS1="$(powerline-go ${toString cfg.args})"
      }
      [ "$TERM" = "linux" ] || PROMPT_COMMAND="_fix_partial_lines; _update_ps1; $PROMPT_COMMAND"
    '';

  };
}
