{ pkgs, ... }:
{
  sconfig = {
    gnome = true;
    profile = "desktop";
    security-tools = true;
  };

  networking.search = [ "bck.me" ];

  environment.systemPackages = with pkgs; [
    wine
    vmware-horizon-client
  ];

  services.openssh.enable = true;

  boot = {
    kernelPackages = pkgs.linuxPackages_latest;
    loader.systemd-boot.enable = true;
    loader.efi.canTouchEfiVariables = true;
    kernelParams = map (x: "video=DP-${x}:1280x720@60") [ "0" "1" "2" ];
    initrd.luks.devices.cryptroot1 = { allowDiscards = true; device = "/dev/disk/by-partlabel/_root1"; };
    initrd.luks.devices.cryptroot2 = { allowDiscards = true; device = "/dev/disk/by-partlabel/_root2"; };
  };

  fileSystems = {
    "/" = { device = "/dev/disk/by-label/_root"; fsType = "btrfs"; options = [ "discard" "compress=zstd:1" ]; };
    "/boot" = { device = "/dev/disk/by-partlabel/_esp"; fsType = "vfat"; };
  };

  system.stateVersion = "21.05";
}
