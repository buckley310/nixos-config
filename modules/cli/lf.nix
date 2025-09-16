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
      video/*)
        ${pkgs.ffmpegthumbnailer}/bin/ffmpegthumbnailer -s0 -o ~/.cache/lf-preview.png -i "$1"
        ${pkgs.chafa}/bin/chafa -s "$2"x"$3" --animate off --polite on -t 1 --bg black ~/.cache/lf-preview.png
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
