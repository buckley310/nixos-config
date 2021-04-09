{ unstable, stable2009 }:
let

  commonModules = name: [
    (../.)
    (./. + "/${name}")
    ({ ... }: {
      config = {
        networking.hostName = name;
        sconfig.flakes.enable = true;
        sconfig.flakes.rebuildPath = "github:buckley310/nixos-config";
      };
    })
  ];

  mkStandardSystem = { name, pkgs }: pkgs.lib.nixosSystem {
    system = "x86_64-linux";
    modules = (commonModules name) ++ [
      pkgs.nixosModules.notDetected
    ];
  };

  mkQemuSystem = { name, pkgs }: pkgs.lib.nixosSystem {
    system = "x86_64-linux";
    modules = (commonModules name) ++ [
      (x: { imports = [ "${x.modulesPath}/profiles/qemu-guest.nix" ]; })
    ];
  };

in
{
  vm = mkQemuSystem { name = "vm"; pkgs = unstable; };
  hp = mkStandardSystem { name = "hp"; pkgs = unstable; };
  manta = mkStandardSystem { name = "manta"; pkgs = unstable; };
  neo = mkStandardSystem { name = "neo"; pkgs = unstable; };
}
