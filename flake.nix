{
  inputs.unstable.url = "nixpkgs/nixos-unstable";
  inputs.stable2009.url = "nixpkgs/nixos-20.09";

  outputs = { self, nixpkgs, ... }@inputs: {
    nixosModule = { ... }: {
      imports = [ ./. ];
      config = { sconfig.flakes.enable = true; };
    };
    nixosConfigurations = import ./hosts { inherit (inputs) unstable stable2009; };
  };
}
