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

    environment.systemPackages = with pkgs; [
      fuzzel
      hyprlock
      hyprshot
      nautilus
      playerctl
      swayidle
      vimix-cursors
      waybar
    ];
  };
}
