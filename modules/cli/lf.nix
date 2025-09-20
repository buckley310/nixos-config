{ pkgs, ... }:
let

  previewer = pkgs.writeShellScript "preview" ''
    case "$(${pkgs.file}/bin/file -Lb --mime-type -- "$1")" in
      image/*)
        ${pkgs.chafa}/bin/chafa -s "$2"x"$3" --animate off --polite on -t 1 --bg black -- "$1"
      ;;
      text/*)
        ${pkgs.bat}/bin/bat --decorations=never --color=always --paging=never -- "$1"
      ;;
      *)
        ${pkgs.file}/bin/file -Lb -- "$1"
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
