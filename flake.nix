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
      nixosModules = {
        inherit (impermanence.nixosModules) impermanence;

        alacritty = import ./modules/alacritty.nix;
        baseline = import ./modules/baseline.nix;
        cli = import ./modules/cli.nix;
        desktop = import ./modules/desktop.nix;
        gnome = import ./modules/gnome.nix;
        gnome-monitor-settings-tweak = import ./modules/gnome-monitor-settings-tweak;
        i3 = import ./modules/i3;
        mouse-dpi = import ./modules/mouse-dpi.nix;
        phpipam = import ./modules/phpipam.nix;
        pipewire = import ./modules/pipewire.nix;
        plasma = import ./modules/plasma.nix;
        profiles = import ./modules/profiles.nix;
        scansnap_s1300 = import ./modules/scansnap_s1300.nix;
        scroll-boost = import ./modules/scroll-boost;
        security-tools = import ./modules/security-tools.nix;
        server = import ./modules/server.nix;
        status-on-console = import ./modules/status-on-console.nix;
        sway = import ./modules/sway.nix;
      };

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
