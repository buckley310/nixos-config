{
  pkgs = "unstable";
  system = "x86_64-linux";
  hardware = "qemu";
  module = ./configuration.nix;
}
