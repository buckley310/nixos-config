{ ... }:
{
  services.xserver = {
    enable = true;
    libinput.enable = true;
    displayManager.sddm.enable = true;
    desktopManager.plasma5.enable = true;
  };
}
