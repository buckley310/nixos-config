{
  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  inputs.stable2009.url = "github:NixOS/nixpkgs/nixos-20.09";

  outputs = { self, nixpkgs, stable2009 }: {
    nixosModule = { ... }: {
      imports = [ ./. ];
      config = { sconfig.flakes.enable = true; };
    };
    nixosConfigurations = import ./hosts { inherit nixpkgs stable2009; };
  };
}
