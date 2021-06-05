{
  inputs.nixpkgs.url = "nixpkgs/nixos-21.05";
  inputs.unstable.url = "nixpkgs/nixos-unstable";

  outputs = { self, ... }@inputs:
    {
      nixosModule = { ... }: { imports = [ ./. ]; };

      nixosConfigurations = self.lib.getHosts inputs ./hosts;

      lib.getHosts = import lib/hosts.nix;
    };
}
