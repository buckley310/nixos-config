{
  # NVIDIA-only using MUX switch in BIOS.
  environment.variables.MUTTER_DEBUG_FORCE_KMS_MODE = "simple";
  hardware.nvidia.modesetting.enable = true;
  hardware.nvidia.open = false;
  services.xserver.videoDrivers = [ "nvidia" ];
}
