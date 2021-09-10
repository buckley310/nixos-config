{ path, nixosModule, unstable, ... }@inputs:
let

  hostMetadata = builtins.mapAttrs
    (name: _: import (path + "/${name}"))
    (builtins.readDir path);

  hardwareModules =
    {
      physical = (x: {
        imports = [ "${x.modulesPath}/installer/scan/not-detected.nix" ];
      });
      vmware = (x: {
        virtualisation.vmware.guest.enable = true;
        boot.initrd.availableKernelModules = [ "mptspi" ];
      });
      qemu = (x: {
        services.qemuGuest.enable = true;
        imports = [ "${x.modulesPath}/profiles/qemu-guest.nix" ];
      });
    };

  getHostConfig = hostName: hostMeta:
    inputs.${hostMeta.pkgs}.lib.nixosSystem
      {
        inherit (hostMeta) system;
        modules = [
          (nixosModule)
          (hostMeta.module)
          (hardwareModules.${hostMeta.hardware})
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
