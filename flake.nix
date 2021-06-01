{
  inputs.unstable.url = "github:NixOS/nixpkgs/nixos-unstable";
  inputs.stable2105.url = "github:NixOS/nixpkgs/nixos-21.05";

  outputs = { self, unstable, stable2105 }: {
    nixosModule = { ... }: {
      imports = [ ./. ];
    };
    nixosConfigurations = import ./hosts { modules = [ ./. ]; inherit unstable stable2105; };
  };
}
