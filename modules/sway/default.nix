{ config, pkgs, ... }:
{
  programs.sway.enable = true;


  environment.variables.GTK_THEME = "Yaru-dark";
  environment.variables.MOZ_ENABLE_WAYLAND = "1";

  environment.etc."xdg/gtk-3.0/settings.ini".text = ''
    [Settings]
    gtk-theme-name=Yaru-dark
    gtk-icon-theme-name=Numix
  '';

  services.gvfs.enable = true;
  programs.dconf.enable = true;
  networking.networkmanager.enable = true;

  environment.systemPackages = with pkgs; [
    numix-icon-theme
    yaru-theme
    gnome3.networkmanagerapplet
    gnome3.file-roller
    gnome3.adwaita-icon-theme
    mate.mate-terminal
    xfce.thunar
    i3status
    xfce.thunar-archive-plugin
    caffeine-ng
    wf-recorder
    xdg_utils
  ];

  programs.bash.interactiveShellInit = '' [ "$(tty)" = "/dev/tty1" ] && exec sway '';
}
