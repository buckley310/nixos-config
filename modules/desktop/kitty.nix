{ config, lib, pkgs, ... }:
{
  environment.systemPackages = [ pkgs.kitty ];
  environment.etc."xdg/kitty/kitty.conf".text = ''
    include ${pkgs.kitty-themes}/share/kitty-themes/themes/Tango_Dark.conf
    term xterm-256color
    background #1e1e1e
    font_size 12
  '';
}
