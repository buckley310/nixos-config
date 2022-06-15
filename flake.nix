{
  inputs.nixpkgs.url = "nixpkgs/nixos-22.05";

  outputs = { self, nixpkgs, ... }:
    let

      mypkgs = import ./pkgs;
      deploy = import lib/deploy.nix;

      hardware = import lib/hardware.nix;

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
      lib = { inherit forAllSystems hardware deploy; };

      nixosModules = mods // { default.imports = builtins.attrValues mods; };

      nixosConfigurations =
        import ./hosts nixpkgs hardware self.nixosModules.default;

      apps = forAllSystems (system:
        import lib/apps.nix nixpkgs.legacyPackages.${system});

      packages = forAllSystems (system:
        mypkgs nixpkgs.legacyPackages.${system});
    };
}
