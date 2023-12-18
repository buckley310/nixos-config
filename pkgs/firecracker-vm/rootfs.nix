{ e2fsprogs
, pkgsStatic
, runCommand
, util-linux
, writeShellScript
}:

let
  init-sh = builtins.toFile "init.sh" ''
    #!/bin/sh
    mount none -t proc /proc
    mount none -t sysfs /sys
    mount none -t tmpfs /tmp
    mount none -t tmpfs /run
    exec sh
  '';

  mkroot = writeShellScript "mkroot" ''
    mkdir -p rootfs/{dev,proc,run,sys,tmp}
    install -Dm 755 ${init-sh} rootfs/sbin/init
    install -Dm 755 ${pkgsStatic.busybox}/bin/busybox rootfs/bin/busybox
    chroot rootfs /bin/busybox --install -s /bin
    ${e2fsprogs.bin}/bin/mkfs.ext4 -d rootfs $out 32M
  '';

in
runCommand "rootfs.img" { } ''
  ${util-linux}/bin/unshare -r ${mkroot}
''
