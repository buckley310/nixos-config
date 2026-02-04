{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.sconfig.hypr;
in
{

  options.sconfig.hypr.enable = lib.mkEnableOption "Hyprland Desktop";

  config = lib.mkIf cfg.enable {
    hardware.graphics.enable = true;
    programs.hyprland.enable = true;

    environment.variables.ELECTRON_OZONE_PLATFORM_HINT = "auto";

    environment.extraInit = lib.mkAfter ''
      [ $(tty) = /dev/tty1 ] &&
        exec start-hyprland
    '';

    # programs.hyprland.withUWSM = true;
    # environment.extraInit = lib.mkAfter ''
    #   [ $(tty) = /dev/tty1 ] &&
    #     uwsm check may-start &&
    #     exec uwsm start hyprland-uwsm.desktop
    # '';

    environment.etc."bck-settings.sh".text = ''
      dconf write /org/gnome/desktop/interface/color-scheme '"prefer-dark"'
    '';

    environment.systemPackages = with pkgs; [
      adwaita-icon-theme
      fuzzel
      gammastep
      hyprlock
      hyprshot
      playerctl
      pulseaudio
      swayidle
      waybar
    ];
  };
}
