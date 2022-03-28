{
  inputs.nixpkgs.url = "nixpkgs/nixos-21.11";
  inputs.nixos-hardware.url = "github:NixOS/nixos-hardware";

  outputs = { self, nixpkgs, nixos-hardware, ... }:
    let

      mypkgs = import ./pkgs;
      deploy = import lib/deploy.nix;

      hardware =
        nixos-hardware.nixosModules //
        import lib/hardware.nix;

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

      nixosConfigurations = import ./hosts nixpkgs hardware self.nixosModule;

      packages = forAllSystems
        (system: mypkgs nixpkgs.legacyPackages.${system});

      apps = forAllSystems (system:
        with nixpkgs.legacyPackages.${system};
        {
          jupyterlab =
            let
              jupy = python3.withPackages (p: with p; [ jupyterlab ipython ]);
            in
            writeShellScriptBin "jupyterlab" ''
              exec ${jupy}/bin/python -m jupyterlab "$@"
            '';

          qemu-uefi = writeShellScriptBin "qemu-uefi" ''
            exec ${qemu_kvm}/bin/qemu-kvm -bios ${OVMF.fd}/FV/OVMF.fd "$@"
          '';
        }
      );
    };
}
