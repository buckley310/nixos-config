{
  inputs.nixpkgs.url = "nixpkgs/nixos-unstable";
  inputs.impermanence.url = "github:nix-community/impermanence";

  outputs = { self, nixpkgs, impermanence, ... }:
    let
      inherit (nixpkgs) lib;

      mypkgs = pkgs:
        let
          pkg = path:
            let
              p = pkgs.callPackage path { };
            in
            if p.meta.available then p else pkgs.emptyDirectory;
        in
        (lib.mapAttrs'
          (name: type: {
            name = lib.removeSuffix ".nix" name;
            value = pkg (./pkgs + "/${name}");
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
        inherit forAllSystems;
        deploy = import lib/deploy.nix;
      };

      nixosModules = mods // { default.imports = builtins.attrValues mods; };

      nixosConfigurations = builtins.mapAttrs
        (_: lib.nixosSystem)
        (import ./hosts self.nixosModules.default);

      apps = forAllSystems (system:
        import lib/apps.nix nixpkgs.legacyPackages.${system});

      packages = forAllSystems (system:
        mypkgs nixpkgs.legacyPackages.${system});
    };
}
