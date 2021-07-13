callerInputs: hostsPath:
let

  hostMetadata = builtins.mapAttrs
    (name: _: import (hostsPath + "/${name}"))
    (builtins.readDir hostsPath);

  hardwareModules =
    {
      physical = (x: { imports = [ "${x.modulesPath}/installer/scan/not-detected.nix" ]; });
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
    callerInputs.${hostMeta.pkgs}.lib.nixosSystem
      {
        inherit (hostMeta) system;
        modules = [
          (callerInputs.self.nixosModule)
          (hostMeta.module)
          (hardwareModules.${hostMeta.hardware})
          (_: { networking.hostName = hostName; })
          (_: {
            nixpkgs.overlays = [
              (_: _: { unstable = callerInputs.unstable.legacyPackages.${hostMeta.system}; })
            ];
          })
        ];
      };

in
builtins.mapAttrs getHostConfig hostMetadata
