{ config, ... }:
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
    open = true;
  };

  # environment.variables.MUTTER_DEBUG_FORCE_KMS_MODE = "simple";
}
