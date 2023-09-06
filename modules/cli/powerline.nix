{ config, lib, pkgs, ... }:
let
  left_hard_divider = builtins.fromJSON '' "\uE0B0" '';
  upper_left_triangle = builtins.fromJSON '' "\uE0BC" '';

  theme = {
    BoldForeground = true;
    CwdFg = 231;
    PathBg = 24;
    PathFg = 231;
    SeparatorFg = 16;
  };

  customEnd = [{
    Content = "$";
    Foreground = 231;
    Background = 102;
    Separator = left_hard_divider;
  }];

  plconfig = builtins.toFile "powerline-config.json" (builtins.toJSON {
    modes.patched.Separator = upper_left_triangle;
  });

  args = [
    "-modules=\${remote:+'user,host,'}nix-shell,git,jobs,cwd,newline,customend"
    "-git-assume-unchanged-size 0"
    "-theme /etc/powerline-theme.json"
    "-path-aliases '~/git=~/git'"
    "-jobs $(jobs -pr | wc -l)"
  ];

in
{
  environment.systemPackages = [
    pkgs.powerline-go

    (pkgs.writeShellScriptBin
      "powerline-go-customend"
      "echo '${builtins.toJSON customEnd}'")
  ];

  environment.etc."powerline-theme.json".text = builtins.toJSON theme;

  programs.bash.interactiveShellInit = ''
    install -D ${plconfig} ~/.config/powerline-go/config.json
    function _update_ps1() {
      local remote=y
      [ "$XDG_SESSION_TYPE" = "x11" ] && unset remote
      [ "$XDG_SESSION_TYPE" = "wayland" ] && unset remote
      PS1="$(powerline-go ${toString args})"
    }
    [ "$TERM" = "linux" ] || PROMPT_COMMAND="_update_ps1; $PROMPT_COMMAND"
  '';
}
