{
  inputs.nixpkgs.url = "nixpkgs/nixos-21.05";
  inputs.unstable.url = "nixpkgs/nixos-unstable";

  outputs = { self, nixpkgs, ... }@inputs:
    {
      nixosModules = {
        baseline = ./modules/baseline.nix;
        cli = ./modules/cli.nix;
        gnome = ./modules/gnome.nix;
        gnome-monitor-settings-tweak = ./modules/gnome-monitor-settings-tweak;
        mouse-dpi = ./modules/mouse-dpi.nix;
        phpipam = ./modules/phpipam.nix;
        pipewire = ./modules/pipewire.nix;
        plasma = ./modules/plasma.nix;
        profiles = ./modules/profiles.nix;
        scansnap_s1300 = ./modules/scansnap_s1300.nix;
        scroll-boost = ./modules/scroll-boost;
        security-tools = ./modules/security-tools.nix;
        status-on-console = ./modules/status-on-console.nix;
        sway = ./modules/sway.nix;
      };

      nixosModule = { ... }: { imports = builtins.attrValues self.nixosModules; };

      nixosConfigurations = self.lib.getHosts inputs ./hosts;

      lib = {
        getHosts = import lib/hosts.nix;
        forAllSystems = f: builtins.listToAttrs (map
          (name: { inherit name; value = f name; })
          (nixpkgs.lib.platforms.all)
        );
      };

      packages = self.lib.forAllSystems (system:
        with nixpkgs.legacyPackages.${system};
        {
          binaryninja = callPackage ./pkgs/binary-ninja-personal { };
          commander-x16 = callPackage ./pkgs/commander-x16 { };
          gef = callPackage ./pkgs/gef { };
          packettracer = callPackage ./pkgs/packettracer { };
          weevely = callPackage ./pkgs/weevely { };
        }
      );

      apps = self.lib.forAllSystems (system:
        with nixpkgs.legacyPackages.${system};
        let
          binScript = x: writeShellScriptBin "script" "exec ${x}";
          jupy = python3.withPackages (p: with p; [ jupyterlab ipython ]);
        in
        {
          luks-mirror = binScript ./misc/luks-mirror.sh;
          luks-single = binScript ./misc/luks-single.sh;

          jupyterlab = writeShellScriptBin "jupyterlab" ''
            exec ${jupy}/bin/python -m jupyterlab "$@"
          '';
        }
      );
    };
}
