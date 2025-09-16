{ pkgs, ... }:
{
  environment.systemPackages = [ pkgs.foot ];
  environment.etc."xdg/foot/foot.ini".text = ''
    [main]
    font=DejaVuSansMono:size=14
  '';
}
