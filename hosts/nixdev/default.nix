{
  pkgs = "nixpkgs";
  system = "x86_64-linux";
  hardware = "qemu";
  module = ./configuration.nix;
}
