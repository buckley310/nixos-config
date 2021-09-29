{ path, nixosModule, unstable, ... }@inputs:
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
          (_: {
            nixpkgs.overlays = [
              (_: _: {
                unstable = import unstable {
                  inherit (hostMeta) system;
                  config.allowUnfree = true;
                };
              })
            ];
          })
        ];
      };

in
builtins.mapAttrs getHostConfig hostMetadata
