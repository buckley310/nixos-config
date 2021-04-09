{ unstable, stable2009 }:
let

  commonModules = name: [
    (../.)
    (./. + "/${name}")
    ({ ... }: {
      networking.hostName = name;
      sconfig.flakes.enable = true;
      sconfig.flakes.rebuildPath = "github:buckley310/nixos-config";
    })
  ];

  mkStandardSystem = { name, pkgs, system }: pkgs.lib.nixosSystem {
    inherit system;
    modules = (commonModules name) ++ [
      pkgs.nixosModules.notDetected
    ];
  };

  mkQemuSystem = { name, pkgs, system }: pkgs.lib.nixosSystem {
    inherit system;
    modules = (commonModules name) ++ [
      (x: { imports = [ "${x.modulesPath}/profiles/qemu-guest.nix" ]; })
    ];
  };

in
{
  vm = mkQemuSystem { name = "vm"; system = "x86_64-linux"; pkgs = unstable; };
  hp = mkStandardSystem { name = "hp"; system = "x86_64-linux"; pkgs = unstable; };
  manta = mkStandardSystem { name = "manta"; system = "x86_64-linux"; pkgs = unstable; };
  neo = mkStandardSystem { name = "neo"; system = "x86_64-linux"; pkgs = unstable; };
}
