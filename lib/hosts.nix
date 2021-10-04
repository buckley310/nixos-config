{ path, nixosModule, ... }@inputs:
let

  hostMetadata = builtins.mapAttrs
    (name: _: import (path + "/${name}"))
    (builtins.readDir path);

  getHostConfig = hostName: hostMeta:
    inputs.${hostMeta.pkgs}.lib.nixosSystem
      {
        inherit (hostMeta) system;
        modules = [
          (nixosModule)
          (hostMeta.module)
          (_: { networking.hostName = hostName; })
        ];
      };

in
builtins.mapAttrs getHostConfig hostMetadata
