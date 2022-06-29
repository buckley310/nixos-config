pkgs:
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

  qemu-uefi = ''
    exec ${pkgs.qemu_kvm}/bin/qemu-kvm -bios ${pkgs.OVMF.fd}/FV/OVMF.fd "$@"
  '';
}
