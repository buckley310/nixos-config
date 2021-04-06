{ unstable, stable2009 }:
let
  mkStandardSystem = { name, pkgs }: pkgs.lib.nixosSystem {
    system = "x86_64-linux";
    modules = [
      pkgs.nixosModules.notDetected
      (./. + "/configuration_${name}.nix")
      ../.
    ];
  };

  mkQemuSystem = { name, pkgs }: pkgs.lib.nixosSystem {
    system = "x86_64-linux";
    modules = [
      ({ modulesPath, ... }: { imports = [ "${modulesPath}/profiles/qemu-guest.nix" ]; })
      (./. + "/configuration_${name}.nix")
      ../.
    ];
  };

in
{
  vm = mkQemuSystem { name = "vm"; pkgs = unstable; };
}
