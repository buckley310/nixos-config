{
  physical = { lib, ... }: lib.mkMerge
    [
      { hardware.cpu.amd.updateMicrocode = true; }
      { hardware.cpu.intel.updateMicrocode = true; }
      { hardware.enableRedistributableFirmware = true; }
    ];

  qemu = { config, lib, modulesPath, ... }: lib.mkMerge
    [
      (import "${modulesPath}/profiles/qemu-guest.nix" { inherit config lib; })
      { services.qemuGuest.enable = true; }
    ];

  vmware = { lib, ... }: lib.mkMerge
    [
      { virtualisation.vmware.guest.enable = true; }
    ];
}
