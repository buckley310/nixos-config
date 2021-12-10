{
  inputs.nixpkgs.url = "nixpkgs/nixos-21.11";

  outputs = { self, nixpkgs, ... }:
    let

      mypkgs = import ./pkgs;
      morphHosts = import lib/morph.nix;
      hardware = import lib/hardware.nix;

      forAllSystems = f: builtins.listToAttrs (map
        (name: { inherit name; value = f name; })
        (with nixpkgs.lib.systems.supported; tier1 ++ tier2));

      pins = {
        nix.registry.nixpkgs.flake = nixpkgs;
        nix.registry.bck.to = {
          owner = "buckley310";
          repo = "nixos-config";
          type = "github";
        };
      };

    in
    {
      lib = { inherit forAllSystems morphHosts hardware; };

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
        nixpkgs.overlays = [ (_: mypkgs) ];
      };

      nixosConfigurations = import ./hosts nixpkgs hardware self.nixosModule;

      packages = forAllSystems
        (system: mypkgs nixpkgs.legacyPackages.${system});

      apps = forAllSystems (system:
        with nixpkgs.legacyPackages.${system};
        {
          gnome-extensions = writeShellScriptBin "gnome-extensions" ''
            cat ${path}/pkgs/desktops/gnome/extensions/extensions.json |
            ${jq}/bin/jq -c '.[]|{name,ver:(.shell_version_map|keys)}'
          '';

          jupyterlab =
            let
              jupy = python3.withPackages (p: with p; [ jupyterlab ipython ]);
            in
            writeShellScriptBin "jupyterlab" ''
              exec ${jupy}/bin/python -m jupyterlab "$@"
            '';
        }
      );
    };
}
