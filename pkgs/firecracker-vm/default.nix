{
  callPackage,
  firecracker,
  writeShellApplication,
  writeText,
}:

let
  kernel = callPackage ./kernel.nix { };
  rootfs = callPackage ./rootfs.nix { };

  vmconfig = writeText "vmconfig.json" (
    builtins.toJSON {
      boot-source = {
        kernel_image_path = "${kernel}/vmlinux";
        boot_args = "panic=1 console=ttyS0 ro";
      };
      drives = [
        {
          drive_id = "rootfs";
          path_on_host = rootfs;
          is_root_device = true;
          is_read_only = true;
        }
      ];
      machine-config.vcpu_count = 2;
      machine-config.mem_size_mib = 1024;
      network-interfaces = [ ];
    }
  );

in
writeShellApplication {
  name = "firecracker-vm";
  text = "${firecracker}/bin/firecracker --no-api --config-file ${vmconfig}";
  derivationArgs.passthru = {
    inherit kernel rootfs;
  };
}
