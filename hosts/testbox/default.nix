{ config, lib, modulesPath, pkgs, ... }:
{
  sconfig.gnome = true;
  sconfig.desktop.enable = true;
  services.getty.autologinUser = "root";
  system.stateVersion = "99.99";

  virtualisation.memorySize = 4096;
  imports = [
    (modulesPath + "/virtualisation/qemu-vm.nix")
  ];
}
