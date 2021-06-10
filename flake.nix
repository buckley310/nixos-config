{
  inputs.nixpkgs.url = "nixpkgs/nixos-21.05";
  inputs.unstable.url = "nixpkgs/nixos-unstable";

  outputs = { self, nixpkgs, ... }@inputs:
    {
      nixosModule = { ... }: { imports = [ ./. ]; };

      nixosConfigurations = self.lib.getHosts inputs ./hosts;

      lib.getHosts = import lib/hosts.nix;

      packages."x86_64-linux" =
        with (import nixpkgs { system = "x86_64-linux"; });
        {
          binaryninja = callPackage ./pkgs/binary-ninja-personal { };
        };
    };
}
