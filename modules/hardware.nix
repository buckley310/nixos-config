{ config, lib, modulesPath, ... }:
let

  hardwareFor = name: cfg:
    lib.mkIf
      (config.sconfig.hardware == name)
      (lib.mkMerge cfg);

  hardwareModules =
    [
      (hardwareFor "qemu"
        [
          (import "${modulesPath}/profiles/qemu-guest.nix" { })
          { services.qemuGuest.enable = true; }
        ])

      (hardwareFor "vmware"
        [
          { virtualisation.vmware.guest.enable = true; }
          { boot.initrd.availableKernelModules = [ "mptspi" ]; }
        ])

      (hardwareFor "physical"
        [
          (import "${modulesPath}/installer/scan/not-detected.nix" { inherit lib; })
          { hardware.cpu.amd.updateMicrocode = true; }
          { hardware.cpu.intel.updateMicrocode = true; }
        ])
    ];

in
with lib;
{
  options.sconfig.hardware = mkOption {
    type = types.enum [ "physical" "vmware" "qemu" ];
  };

  config = mkMerge hardwareModules;
}
