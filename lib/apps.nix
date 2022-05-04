pkgs:
{
  jupyterlab =
    let
      jupy = pkgs.python3.withPackages (p: with p; [ jupyterlab ipython ]);
    in
    pkgs.writeShellScriptBin "jupyterlab" ''
      exec ${jupy}/bin/python -m jupyterlab "$@"
    '';

  qemu-uefi = pkgs.writeShellScriptBin "qemu-uefi" ''
    exec ${pkgs.qemu_kvm}/bin/qemu-kvm -bios ${pkgs.OVMF.fd}/FV/OVMF.fd "$@"
  '';
}
