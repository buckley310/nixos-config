{ config, lib, pkgs, ... }:
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

  sconfig = {
    gnome = true;
    desktop.enable = true;
    horizon.enable = true;
    wg-home = { enable = true; path = "${persist}/wireguard_home.conf"; };
  };

  environment.persistence."${persist}/system".directories = [
    "/etc/NetworkManager/system-connections"
    "/var/lib/bluetooth"
    "/var/lib/nixos"
    "/var/lib/systemd/coredump"
    "/var/log/journal"
  ];

  programs.bash.interactiveShellInit = ''
    function eco() {
      taskset -p ff000 $$
    }
  '';

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

  services.zfs.trim.interval = "03:05";

  hardware.cpu.intel.updateMicrocode = true;
  hardware.enableRedistributableFirmware = true;
  system.stateVersion = "22.05";
}
