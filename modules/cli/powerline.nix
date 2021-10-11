{ config, pkgs, lib, ... }:
let
  cfg = config.sconfig.powerline;
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
          "-colorize-hostname"
          "-cwd-mode=plain"
          "-modules=user,host,cwd,nix-shell,git,jobs"
          "-git-assume-unchanged-size 0"
          "-jobs $(jobs -p | wc -l)"
        ];
      };
    };

  config = lib.mkIf cfg.enable {

    environment.systemPackages = [ pkgs.powerline-go ];

    programs.bash.interactiveShellInit = ''
      function _update_ps1() {
        PS1="\n$(powerline-go ${lib.concatStringsSep " " cfg.args})$ "
      }
      [ "$TERM" = "linux" ] || PROMPT_COMMAND="_update_ps1; $PROMPT_COMMAND"
    '';

  };
}
