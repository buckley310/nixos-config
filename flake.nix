{
  inputs = {
    nixpkgs.url = "nixpkgs/nixos-unstable";
  };

  outputs =
    {
      self,
      nixpkgs,
    }:
    let
      inherit (nixpkgs) lib;

      mypkgs =
        pkgs:
        self.lib.dirToAttrs ./pkgs (x: pkgs.callPackage x { })
        // {
          iso = import lib/gen-iso.nix lib pkgs.stdenv.hostPlatform.system;
        };

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
      lib = {
        base64 = import lib/base64.nix;
        ssh-keys = import lib/ssh-keys.nix;

        dirToAttrs =
          dir: f:
          lib.mapAttrs' (name: _: {
            name = lib.removeSuffix ".nix" name;
            value = f "${toString dir}/${name}";
          }) (builtins.readDir dir);
      };

      nixosModules = self.lib.dirToAttrs ./modules import // {
        inherit pins;
        pkgs.nixpkgs.overlays = [ (_: mypkgs) ];
      };

      nixosConfigurations = self.lib.dirToAttrs ./hosts (
        dir:
        let
          cfg = import dir;
        in
        lib.nixosSystem {
          inherit (cfg) system;
          modules =
            cfg.modules
            ++ [ { networking.hostName = builtins.baseNameOf dir; } ]
            ++ (builtins.attrValues self.nixosModules);
        }
      );

      packages = forAllSystems (system: mypkgs nixpkgs.legacyPackages.${system});
    };
}
