{ nixpkgs, stable2009 }:
let

  commonModules = [
    ../.
    ({ ... }: {
      config = {
        sconfig.flakes.enable = true;
        sconfig.flakes.rebuildPath = "github:buckley310/nixos-config";
      };
    })
  ];

  mkStandardSystem = { name, pkgs }: pkgs.lib.nixosSystem {
    system = "x86_64-linux";
    modules = commonModules ++ [
      pkgs.nixosModules.notDetected
      (./. + "/configuration_${name}.nix")
    ];
  };

  mkQemuSystem = { name, pkgs }: pkgs.lib.nixosSystem {
    system = "x86_64-linux";
    modules = commonModules ++ [
      (x: { imports = [ "${x.modulesPath}/profiles/qemu-guest.nix" ]; })
      (./. + "/configuration_${name}.nix")
    ];
  };

in
{
  vm = mkQemuSystem { name = "vm"; pkgs = nixpkgs; };
  manta = mkStandardSystem { name = "manta"; pkgs = nixpkgs; };
}
