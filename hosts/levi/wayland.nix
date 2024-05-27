{ config, ... }:
{
  # NVIDIA-only using MUX switch in BIOS.
  environment.variables.MUTTER_DEBUG_FORCE_KMS_MODE = "simple";
  hardware.nvidia.modesetting.enable = true;
  hardware.nvidia.open = false;
  services.xserver.videoDrivers = [ "nvidia" ];

  # Nvidia driver 555 is significant for wayland support.
  # Currently version 555 is beta.
  hardware.nvidia.package = builtins.trace
    "Using beta nvidia driver"
    config.boot.kernelPackages.nvidiaPackages.beta;
}
