{ config, lib, pkgs, ... }:

# This is a temporary workaround for
# https://github.com/NixOS/nixpkgs/issues/131539

{
  nixpkgs.overlays = [
    (self: super: {
      vlang = super.vlang.overrideAttrs (_: {
        postInstall = ''
          find $out/lib/cmd/tools -maxdepth 1 -name 'v*.v' |
            HOME=$TMPDIR xargs -P0 -n1 ${pkgs.python3}/bin/python -c \
              'import os,sys,pty; pty.spawn([os.getenv("out")+"/bin/v",sys.argv[1]])'
        '';
      });
    })
  ];
}
