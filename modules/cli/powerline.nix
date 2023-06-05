{ config, lib, pkgs, ... }:
let

  theme = pkgs.writeText "powerline.json" (builtins.toJSON
    {
      BoldForeground = true;
      CwdFg = 15;
      PathBg = 24;
      PathFg = 15;
      SeparatorFg = 16;
    });

  args = [
    "-modules=\${remote:+'user,host,'}nix-shell,git,jobs,cwd"
    "-git-assume-unchanged-size 0"
    "-theme ${theme}"
    "-path-aliases '~/git=~/git'"
    "-jobs $(jobs -p | wc -l)"
  ];

in
{
  environment.systemPackages = [ pkgs.powerline-go ];

  programs.bash.interactiveShellInit = ''
    function _update_ps1() {
      local remote=y
      [ "$XDG_SESSION_TYPE" = "x11" ] && unset remote
      [ "$XDG_SESSION_TYPE" = "wayland" ] && unset remote
      PS1="$(powerline-go ${toString args})"
    }
    [ "$TERM" = "linux" ] || PROMPT_COMMAND="_update_ps1; $PROMPT_COMMAND"
  '';
}
