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

    in
    {
      lib = { inherit forAllSystems hardware deploy; };

      nixosModules =
        { inherit pins; } //
        nixpkgs.lib.mapAttrs'
          (name: type: {
            name = nixpkgs.lib.removeSuffix ".nix" name;
            value = import (./modules + "/${name}");
          })
          (builtins.readDir ./modules);

      nixosModule = {
        imports = builtins.attrValues self.nixosModules;
        nixpkgs.overlays = [
          (_: mypkgs)
        ];
      };

      nixosConfigurations =
        import ./hosts nixpkgs hardware self.nixosModule;

      apps = forAllSystems (system:
        import lib/apps.nix nixpkgs.legacyPackages.${system});

      packages = forAllSystems (system:
        mypkgs nixpkgs.legacyPackages.${system});
    };
}
