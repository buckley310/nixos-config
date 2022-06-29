pkgs:
let
  qemu-opts = builtins.concatStringsSep " " [
    "${pkgs.qemu_kvm}/bin/qemu-kvm"
    "-cpu host"
    "-usbdevice tablet"
    "-smp $(nproc)"
    "-m 4096"
  ];

in
builtins.mapAttrs
  (n: v: {
    type = "app";
    program = toString (pkgs.writeShellScript n v);
  })
{
  jupyterlab =
    let
      jupy = pkgs.python3.withPackages (p: with p; [ jupyterlab ipython ]);
    in
    ''
      exec ${jupy}/bin/python -m jupyterlab "$@"
    '';

  qemu-bios = ''
    exec ${qemu-opts} "$@"
  '';

  qemu-uefi = ''
    exec ${qemu-opts} -bios ${pkgs.OVMF.fd}/FV/OVMF.fd "$@"
  '';
}
