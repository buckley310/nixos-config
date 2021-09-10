{
  inputs.nixpkgs.url = "nixpkgs/nixos-21.05";
  inputs.unstable.url = "nixpkgs/nixos-unstable";
  inputs.impermanence.url = "github:nix-community/impermanence";

  outputs = { self, nixpkgs, unstable, impermanence, ... }:
    let
      mypkgs = pkgs:
        {
          commander-x16 = pkgs.callPackage ./pkgs/commander-x16 { };
          gef = pkgs.callPackage ./pkgs/gef { };
          stretchy-spaces = pkgs.callPackage ./pkgs/stretchy-spaces { };
          weevely = pkgs.callPackage ./pkgs/weevely { };
        }
        // (if pkgs.system != "x86_64-linux" then { } else
        {
          binaryninja = pkgs.callPackage ./pkgs/binary-ninja-personal { };
          packettracer = pkgs.callPackage ./pkgs/packettracer { };
        });
    in
    {
      nixosModules =
        { inherit (impermanence.nixosModules) impermanence; } //
        nixpkgs.lib.mapAttrs'
          (name: type: {
            name = if (type == "regular") then (nixpkgs.lib.removeSuffix ".nix" name) else name;
            value = import (./modules + "/${name}");
          })
          (builtins.readDir ./modules);

      nixosModule = { pkgs, ... }: {
        imports = builtins.attrValues self.nixosModules;
        nixpkgs.overlays = [ (_: mypkgs) ];
      };

      nixosConfigurations = self.lib.getHosts {
        path = ./hosts;
        inherit nixpkgs unstable;
        inherit (self) nixosModule;
      };

      lib = {
        getHosts = import lib/hosts.nix;
        morphHosts = import lib/morph.nix;
        forAllSystems = f: builtins.listToAttrs (map
          (name: { inherit name; value = f name; })
          (builtins.attrNames nixpkgs.legacyPackages)
        );
      };

      packages = self.lib.forAllSystems
        (system: mypkgs nixpkgs.legacyPackages.${system});

      apps = self.lib.forAllSystems (system:
        with nixpkgs.legacyPackages.${system};
        let
          jupy = python3.withPackages (p: with p; [ jupyterlab ipython ]);
        in
        {
          jupyterlab = writeShellScriptBin "jupyterlab" ''
            exec ${jupy}/bin/python -m jupyterlab "$@"
          '';
        }
      );
    };
}
