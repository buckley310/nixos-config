{
  pkgs = "nixpkgs";
  system = "x86_64-linux";
  hardware = "physical";
  module = ./configuration.nix;
}
