{ pkgs, ... }:
let

  previewer = pkgs.writeShellScript "preview" ''
    mime="$(${pkgs.file}/bin/file -Lb --mime-type -- "$1")"
    case "$mime" in
      image/*)
        ${pkgs.chafa}/bin/chafa -s "$2"x"$3" --animate off --polite on -t 1 --bg black -- "$1"
      ;;
      text/*)
        ${pkgs.bat}/bin/bat --decorations=never --color=always --paging=never -- "$1"
      ;;
      *)
        echo "$mime"
      ;;
    esac
  '';

in
{
  environment.systemPackages = [ pkgs.lf ];
  environment.etc."lf/lfrc".text = ''
    set previewer ${previewer}
    set sixel true
  '';
}
