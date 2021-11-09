{
  inputs.nixpkgs.url = "nixpkgs/nixos-unstable";
  inputs.impermanence.url = "github:nix-community/impermanence";

  outputs = { self, nixpkgs, impermanence, ... }:
    let
      mypkgs = import ./pkgs;
    in
    {
      nixosModules =
        { inherit (impermanence.nixosModules) impermanence; } //
        nixpkgs.lib.mapAttrs'
          (name: type: {
            name = nixpkgs.lib.removeSuffix ".nix" name;
            value = import (./modules + "/${name}");
          })
          (builtins.readDir ./modules);

      nixosModule = { pkgs, ... }: {
        imports = builtins.attrValues self.nixosModules;
        nixpkgs.overlays = [ (_: mypkgs) ];
      };

      nixosConfigurations = self.lib.getHosts {
        path = ./hosts;
        inherit nixpkgs;
        inherit (self) nixosModule;
      };

      lib = {
        getHosts = import lib/hosts.nix;
        morphHosts = import lib/morph.nix;
        forAllSystems = f: builtins.listToAttrs (map
          (name: { inherit name; value = f name; })
          (with nixpkgs.lib.systems.supported; tier1 ++ tier2));
      };

      packages = self.lib.forAllSystems
        (system: mypkgs nixpkgs.legacyPackages.${system});

      apps = self.lib.forAllSystems (system:
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
