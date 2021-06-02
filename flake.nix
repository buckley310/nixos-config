{
  inputs.nixpkgs.url = "nixpkgs/nixos-21.05";
  inputs.unstable.url = "nixpkgs/nixos-unstable";

  outputs = { self, unstable, nixpkgs }: {
    nixosModule = { ... }: {
      imports = [ ./. ];
    };
    nixosConfigurations = import ./hosts { modules = [ ./. ]; inherit unstable nixpkgs; };
  };
}
