{
  physical = { lib, ... }: lib.mkMerge
    [
      { hardware.cpu.amd.updateMicrocode = true; }
      { hardware.cpu.intel.updateMicrocode = true; }
      { hardware.enableRedistributableFirmware = true; }
    ];

  qemu = { lib, modulesPath, ... }: lib.mkMerge
    [
      (import "${modulesPath}/profiles/qemu-guest.nix" { })
      { services.qemuGuest.enable = true; }
    ];

  vmware = { lib, ... }: lib.mkMerge
    [
      { virtualisation.vmware.guest.enable = true; }
      { boot.initrd.availableKernelModules = [ "mptspi" ]; }
    ];
}
