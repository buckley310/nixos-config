{
  ### NVIDIA-only using MUX switch in BIOS.
  boot.kernelParams = [ "module_blacklist=i915" ];
  services.xserver.displayManager.gdm.wayland = false;
  services.xserver.videoDrivers = [ "nvidia" ];
  services.xserver.screenSection = ''
    Option "metamodes" "DP-2: 2560x1440_165 +0+0 {AllowGSYNCCompatible=On}"
  '';
}
