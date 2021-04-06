{
  inputs.nixpkgs.url = "nixpkgs/nixos-unstable";
  inputs.stable2009.url = "nixpkgs/nixos-20.09";

  outputs = { self, nixpkgs, stable2009 }: {
    nixosModule = { ... }: {
      imports = [ ./. ];
      config = { sconfig.flakes.enable = true; };
    };
    nixosConfigurations = import ./hosts { inherit nixpkgs stable2009; };
  };
}
