{
  inputs.nixpkgs.url = "nixpkgs/nixos-22.05";

  outputs = { self, nixpkgs, ... }:
    let

      mypkgs = pkgs:
        let
          pkg = path:
            let
              p = pkgs.callPackage path { };
            in
            if p.meta.available then p else pkgs.emptyDirectory;
        in
        (nixpkgs.lib.mapAttrs'
          (name: type: {
            name = nixpkgs.lib.removeSuffix ".nix" name;
            value = pkg (./pkgs + "/${name}");
          })
          (builtins.readDir ./pkgs));

      deploy = import lib/deploy.nix;

      forAllSystems = f: nixpkgs.lib.genAttrs
        [ "x86_64-linux" "aarch64-linux" ]
        (system: f system);

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
          pkgs.nixpkgs.overlays = [ (_: mypkgs) ];
        } //
        nixpkgs.lib.mapAttrs'
          (name: type: {
            name = nixpkgs.lib.removeSuffix ".nix" name;
            value = import (./modules + "/${name}");
          })
          (builtins.readDir ./modules);

    in
    {
      lib = { inherit forAllSystems deploy; };

      nixosModules = mods // { default.imports = builtins.attrValues mods; };

      nixosConfigurations = builtins.mapAttrs
        (_: nixpkgs.lib.nixosSystem)
        (import ./hosts self.nixosModules.default);

      apps = forAllSystems (system:
        import lib/apps.nix nixpkgs.legacyPackages.${system});

      packages = forAllSystems (system:
        mypkgs nixpkgs.legacyPackages.${system});
    };
}
