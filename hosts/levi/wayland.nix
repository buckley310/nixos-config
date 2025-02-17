{
  config,
  lib,
  pkgs,
  ...
}:
{
  # NVIDIA-only using MUX switch in BIOS.

  hardware.graphics = {
    enable = true;
  };

  services.xserver.videoDrivers = [ "nvidia" ];

  hardware.nvidia = {
    modesetting.enable = true;
    package = config.boot.kernelPackages.nvidiaPackages.latest;
    powerManagement.enable = false;
    powerManagement.finegrained = false;
  };

  # environment.variables.MUTTER_DEBUG_FORCE_KMS_MODE = "simple";
  # environment.variables.HYPRLAND_TRACE = "1";

  programs.hyprland.enable = true;
  programs.hyprland.withUWSM = true;
  environment.systemPackages = with pkgs; [
    hyprlock
    nautilus
    playerctl
    swayidle
    vimix-cursors
    waybar
    wofi
  ];
  environment.extraInit = lib.mkAfter ''
    uwsm check may-start && exec uwsm start hyprland-uwsm.desktop
  '';
}
