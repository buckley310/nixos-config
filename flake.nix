{
  inputs.nixpkgs.url = "nixpkgs/nixos-21.05";
  inputs.unstable.url = "nixpkgs/nixos-unstable";

  outputs = { self, nixpkgs, ... }@inputs:
    {
      nixosModules = {
        alacritty = ./modules/alacritty.nix;
        baseline = ./modules/baseline.nix;
        cli = ./modules/cli.nix;
        gnome = ./modules/gnome.nix;
        phpipam = ./modules/phpipam.nix;
        pipewire = ./modules/pipewire.nix;
        profiles = ./modules/profiles.nix;
        scansnap_s1300 = ./modules/scansnap_s1300.nix;
        scroll-boost = ./modules/scroll-boost;
        security-tools = ./modules/security-tools.nix;
        status-on-console = ./modules/status-on-console.nix;
        sway = ./modules/sway.nix;
      };

      nixosModule = { ... }: { imports = builtins.attrValues self.nixosModules; };

      nixosConfigurations = self.lib.getHosts inputs ./hosts;

      lib.getHosts = import lib/hosts.nix;

      packages."x86_64-linux" =
        with (import nixpkgs { system = "x86_64-linux"; });
        {
          binaryninja = callPackage ./pkgs/binary-ninja-personal { };
        };
    };
}
