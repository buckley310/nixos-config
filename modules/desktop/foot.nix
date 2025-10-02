{ pkgs, ... }:
{
  environment.systemPackages = [ pkgs.foot ];
  environment.etc."xdg/foot/foot.ini".text = ''
    [main]
    font=DejaVuSansMono:size=14
    [key-bindings]
    scrollback-up-page=none
    scrollback-down-page=none
    scrollback-up-half-page=Shift+Page_Up
    scrollback-down-half-page=Shift+Page_Down
  '';
}
