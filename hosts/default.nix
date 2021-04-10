{ sconfig, unstable, stable2009 }:
let

  hostMetadata =
    let
      inherit (builtins) readDir concatMap attrNames;
      fs = readDir ./.;
      hostNames = concatMap (x: if fs.${x} == "directory" then [ x ] else [ ]) (attrNames fs);
    in
    map
      (hn: { name = hn; inherit (import (./. + "/${hn}")) hardware pkgs system; })
      hostNames;

  hardwareModule = { pkgs, hardware }: (
    {
      qemu = (x: { imports = [ "${x.modulesPath}/profiles/qemu-guest.nix" ]; });
      physical = pkgs.nixosModules.notDetected;
    }
  ).${hardware};

in
builtins.listToAttrs (
  map
    (h:
      let pkgs = { inherit unstable stable2009; }.${h.pkgs};
      in
      {
        name = h.name;
        value = pkgs.lib.nixosSystem {
          system = h.system;
          modules = [
            (sconfig)
            (./. + "/${h.name}/configuration.nix")
            (hardwareModule { inherit pkgs; inherit (h) hardware; })
            ({ ... }: {
              networking.hostName = h.name;
              sconfig.flakes.enable = true;
              sconfig.flakes.rebuildPath = "github:buckley310/nixos-config";
            })
          ];
        };
      }
    )
    hostMetadata
)
