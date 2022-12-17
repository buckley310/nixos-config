{ config, lib, modulesPath, pkgs, ... }:
{
  sconfig.gnome = true;
  sconfig.profile = "desktop";
  services.getty.autologinUser = "root";

  virtualisation.memorySize = 4096;
  imports = [
    (modulesPath + "/virtualisation/qemu-vm.nix")
  ];
}
