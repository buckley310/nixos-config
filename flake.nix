{
  inputs.nixpkgs.url = "nixpkgs/nixos-unstable";
  inputs.impermanence.url = "github:nix-community/impermanence";

  outputs = { self, nixpkgs, impermanence }:
    let
      inherit (nixpkgs) lib;

      mypkgs = pkgs:
        {
          iso = import lib/gen-iso.nix lib pkgs.system;
        } //
        (lib.mapAttrs'
          (name: type: {
            name = lib.removeSuffix ".nix" name;
            value = pkgs.callPackage (./pkgs + "/${name}") { };
          })
          (builtins.readDir ./pkgs));

      forAllSystems = lib.genAttrs [ "x86_64-linux" ];

      pins = {
        nix.registry.nixpkgs.to = {
          inherit (nixpkgs) rev;
          owner = "NixOS";
          repo = "nixpkgs";
          type = "github";
        };
        nix.registry.bck.to = {
          owner = "buckley310";
          repo = "nixos-config";
          type = "github";
        };
      };

    in
    {
      formatter = forAllSystems (system:
        nixpkgs.legacyPackages.${system}.nixpkgs-fmt);

      lib = {
        gen-ssh-config = import lib/gen-ssh-config.nix lib;
        ssh-keys = import lib/ssh-keys.nix;
      };

      nixosModules =
        {
          inherit pins;
          inherit (impermanence.nixosModules) impermanence;
          pkgs.nixpkgs.overlays = [ (_: mypkgs) ];
        } //
        lib.mapAttrs'
          (name: type: {
            name = lib.removeSuffix ".nix" name;
            value = import (./modules + "/${name}");
          })
          (builtins.readDir ./modules);

      nixosConfigurations = builtins.mapAttrs
        (_: lib.nixosSystem)
        (import ./hosts { imports = builtins.attrValues self.nixosModules; });

      packages = forAllSystems (system:
        mypkgs nixpkgs.legacyPackages.${system});
    };
}
