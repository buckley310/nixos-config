{
  inputs.unstable.url = "github:NixOS/nixpkgs/nixos-unstable";
  inputs.stable2009.url = "github:NixOS/nixpkgs/nixos-20.09";

  outputs = { self, unstable, stable2009 }: {
    nixosModule = { ... }: {
      imports = [ ./. ];
      config = { sconfig.flakes.enable = true; };
    };
    nixosConfigurations = import ./hosts { inherit unstable stable2009; };
  };
}
