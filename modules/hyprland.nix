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
    hardware.bluetooth.enable = true;
    hardware.graphics.enable = true;
    programs.hyprland.enable = true;
    programs.hyprland.withUWSM = true;
    services.blueman.enable = true;

    environment.extraInit = lib.mkAfter ''
      uwsm check may-start && exec uwsm start hyprland-uwsm.desktop
    '';

    environment.etc."bck-settings.sh".text = ''
      dconf write /org/gnome/desktop/interface/color-scheme '"prefer-dark"'
    '';

    environment.systemPackages = with pkgs; [
      adwaita-icon-theme
      fuzzel
      hyprlock
      hyprshot
      nautilus
      playerctl
      swayidle
      waybar
    ];
  };
}
