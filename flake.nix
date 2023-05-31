{
  inputs.nixpkgs.url = "nixpkgs/nixos-unstable";
  inputs.impermanence.url = "github:nix-community/impermanence";

  outputs = { self, nixpkgs, impermanence, ... }:
    let
      inherit (nixpkgs) lib;

      mypkgs = pkgs:
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

      mods =
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

    in
    {
      lib = {
        gen-ssh-config = import lib/gen-ssh-config.nix lib;
        ssh-keys = import lib/ssh-keys.nix;
      };

      nixosModules = mods // { default.imports = builtins.attrValues mods; };

      nixosConfigurations = builtins.mapAttrs
        (_: lib.nixosSystem)
        (import ./hosts self.nixosModules.default);

      packages = forAllSystems (system:
        mypkgs nixpkgs.legacyPackages.${system});
    };
}
