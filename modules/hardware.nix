{ config, pkgs, lib, modulesPath, ... }:
let

  inherit (pkgs) callPackage;

  hardwareFor = name: cfg: lib.mkIf (config.sconfig.hardware == name) cfg;

  hardwareModules =
    [
      (hardwareFor "qemu"
        {
          inherit (callPackage "${modulesPath}/profiles/qemu-guest.nix" { }) boot;
          services.qemuGuest.enable = true;
        })

      (hardwareFor "vmware"
        {
          virtualisation.vmware.guest.enable = true;
          boot.initrd.availableKernelModules = [ "mptspi" ];
        })

      (hardwareFor "physical"
        {
          inherit (callPackage "${modulesPath}/installer/scan/not-detected.nix" { }) hardware;
        })
    ];

in
with lib;
{
  options.sconfig.hardware = mkOption {
    type = types.enum [ "physical" "vmware" "qemu" ];
  };

  config = mkMerge hardwareModules;
}
