{ pkgs, ... }:
{
  sconfig = {
    gnome = true;
    profile = "desktop";
    security-tools = true;
  };

  networking = {
    search = [ "bck.me" ];
  };

  environment.systemPackages = with pkgs; [
    vmware-horizon-client
    wine
    winetricks

    (writeShellScriptBin "work" ''
      xrandr \
      --output DisplayPort-0 --mode 2560x1440 -r 144 --pos 0x0 \
      --output DisplayPort-1 --mode 2560x1440 -r 144 --pos 2560x0 \
      --output DisplayPort-2 --off \
      --output HDMI-A-0      --off \
    '')
    (writeShellScriptBin "game" ''
      xrandr \
      --output DisplayPort-0 --mode 2560x1440 -r 165 --pos 0x0 \
      --output DisplayPort-1 --off \
      --output DisplayPort-2 --off \
      --output HDMI-A-0      --off \
    '')
    (writeShellScriptBin "tv" ''
      xrandr \
      --output DisplayPort-0 --off \
      --output DisplayPort-1 --off \
      --output DisplayPort-2 --off \
      --output HDMI-A-0      --mode 1920x1080 -r 60 --pos 0x0 \
    '')
  ];

  services = {
    openssh.enable = true;
    zfs.autoSnapshot = { enable = true; monthly = 0; weekly = 0; };
  };

  boot = {
    loader.systemd-boot.enable = true;
    loader.efi.canTouchEfiVariables = true;
    kernelParams = map (x: "video=DP-${x}:1280x720@60") [ "0" "1" "2" ];
  };

  fileSystems = {
    "/" = { device = "zroot/locker/os"; fsType = "zfs"; };
    "/home" = { device = "zroot/locker/home"; fsType = "zfs"; };
    "/boot" = { device = "/dev/disk/by-partlabel/_esp"; fsType = "vfat"; };
  };

  system.stateVersion = "20.09";
}
