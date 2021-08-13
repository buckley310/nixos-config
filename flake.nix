{
  inputs.nixpkgs.url = "nixpkgs/nixos-21.05";
  inputs.unstable.url = "nixpkgs/nixos-unstable";

  outputs = { self, nixpkgs, ... }@inputs:
    {
      nixosModules = {
        baseline = import ./modules/baseline.nix;
        cli = import ./modules/cli.nix;
        gnome = import ./modules/gnome.nix;
        gnome-monitor-settings-tweak = import ./modules/gnome-monitor-settings-tweak;
        mouse-dpi = import ./modules/mouse-dpi.nix;
        phpipam = import ./modules/phpipam.nix;
        pipewire = import ./modules/pipewire.nix;
        plasma = import ./modules/plasma.nix;
        profiles = import ./modules/profiles.nix;
        scansnap_s1300 = import ./modules/scansnap_s1300.nix;
        scroll-boost = import ./modules/scroll-boost;
        security-tools = import ./modules/security-tools.nix;
        status-on-console = import ./modules/status-on-console.nix;
        sway = import ./modules/sway.nix;
      };

      nixosModule = { ... }: { imports = builtins.attrValues self.nixosModules; };

      nixosConfigurations = self.lib.getHosts inputs ./hosts;

      lib = {
        getHosts = import lib/hosts.nix;
        forAllSystems = f: builtins.listToAttrs (map
          (name: { inherit name; value = f name; })
          [ "aarch64-linux" "i686-linux" "x86_64-linux" ]
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
