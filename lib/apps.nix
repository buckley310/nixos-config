pkgs:
let
  qemu-opts = builtins.concatStringsSep " " [
    "${pkgs.qemu_kvm}/bin/qemu-kvm"
    "-cpu host"
    "-usbdevice tablet"
    "-smp cores=4"
    "-m 4096"
  ];

in
builtins.mapAttrs
  (n: v: {
    type = "app";
    program = toString (pkgs.writeShellScript n v);
  })
{
  jupyterlab = ''
    jupy=${pkgs.python3.withPackages (p: [ p.jupyterlab p.ipython ])}
    exec $jupy/bin/python -m jupyterlab "$@"
  '';

  qemu-bios = ''
    exec ${qemu-opts} "$@"
  '';

  qemu-uefi = ''
    exec ${qemu-opts} -bios ${pkgs.OVMF.fd}/FV/OVMF.fd "$@"
  '';
}
