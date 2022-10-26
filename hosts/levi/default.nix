{ config, pkgs, ... }:
let
  persist = "/nix/persist";
in
{
  imports = [
    ./optimus.nix
  ];

  environment.etc = {
    "machine-id".source = "${persist}/machine-id";
  };

  services.openssh.hostKeys = [
    { type = "ed25519"; path = "${persist}/ssh_host_ed25519_key"; }
  ];

  # speakers buzz when the onboard DAC suspends
  nixpkgs.overlays = [
    (self: super: {
      wireplumber = super.wireplumber.overrideAttrs (_: {
        postInstall = ''
          sed -i \
            's/.*session.suspend-timeout-seconds.*/["session.suspend-timeout-seconds"]=0,/' \
            $out/share/wireplumber/main.lua.d/50-alsa-config.lua
        '';
      });
    })
  ];

  sconfig = {
    gnome = true;
    profile = "desktop";
    gaming.enable = true;
    horizon.enable = true;
    wg-home = { enable = true; path = "${persist}/wireguard_home.conf"; };
  };

  environment.persistence."${persist}/system".directories = [
    "/etc/NetworkManager/system-connections"
    "/var/lib/nixos"
    "/var/lib/systemd"
    "/var/lib/upower"
    "/var/log"
  ];

  boot = {
    loader.systemd-boot.enable = true;
    loader.efi.canTouchEfiVariables = true;
    initrd.availableKernelModules = [ "xhci_pci" "vmd" "nvme" "sd_mod" ];
  };

  fileSystems = {
    "/" = { device = "tmpfs"; fsType = "tmpfs"; options = [ "mode=755" ]; };
    "/boot" = { fsType = "vfat"; device = "/dev/nvme0n1p1"; };
    "/nix" = { device = "levi/nix"; fsType = "zfs"; };
    "/home" = { device = "levi/home"; fsType = "zfs"; };
  };

  users.mutableUsers = false;
  users.users.sean.passwordFile = "${persist}/shadow_sean";
  users.users.root.passwordFile = "${persist}/shadow_sean";

  services.openssh.enable = true;
  hardware.video.hidpi.enable = true;
  hardware.cpu.intel.updateMicrocode = true;
  hardware.enableRedistributableFirmware = true;
  system.stateVersion = "22.05";
}
