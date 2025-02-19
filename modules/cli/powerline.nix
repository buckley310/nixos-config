{ pkgs, ... }:
let
  theme = {
    BoldForeground = true;
    CwdFg = 231;
    CmdPassedFg = 231;
    CmdPassedBg = 102;
    PathBg = 24;
    PathFg = 231;
    SeparatorFg = 16;
  };

  args = [
    "-modules=\${remote:+'user,host,'}nix-shell,git,jobs,cwd,newline,root"
    "-git-assume-unchanged-size 0"
    "-theme /etc/powerline-theme.json"
    "-path-aliases '~/git=~/git'"
    "-jobs $(jobs -p | wc -l)"
  ];

  termtitle = ''\[\e]0;\u@\h: \w\a\]'';

in
{
  environment.systemPackages = [
    pkgs.powerline-go
  ];

  environment.etc."powerline-theme.json".text = builtins.toJSON theme;

  programs.bash.interactiveShellInit = ''
    function _update_ps1() {
      local remote=y
      [ "$XDG_SESSION_TYPE" = "x11" ] && unset remote
      [ "$XDG_SESSION_TYPE" = "wayland" ] && unset remote
      PS1="${termtitle}$(powerline-go ${toString args})"
    }
    [ "$TERM" = "linux" ] || PROMPT_COMMAND="_update_ps1; $PROMPT_COMMAND"
  '';
}
